//
//  AppDelegate.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/5/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var isTestProject: Bool {
		return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
	}

	var window: UIWindow?
	var isAppFirstOpen: Bool = true
	var cloudSyncTimer: Timer?
	var appSaveTimer: Timer?
	var isClosedApp: Bool = false

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		// Override point for customization after application launch.
		return true
	}

//	func application(
//		_ application: UIApplication,
//		didReceiveRemoteNotification userInfo: [AnyHashable : Any],
//		fetchCompletionHandler completionHandler: @escaping ((UIBackgroundFetchResult) -> Void)
//	) {
//		if let dict = userInfo as? [String: NSObject] {
//			let notification = CKNotification(fromRemoteNotificationDictionary: dict)
//			if (notification.subscriptionID == GamesDataBackup.current.subscriptionId) {
//				GamesDataBackup.current.sync(appState: .running) { (isSynced: Bool) in
//					completionHandler(UIBackgroundFetchResult.newData)
//				}

//			}

//		} else {
//			completionHandler(UIBackgroundFetchResult.newData)
//		}

//	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. 
		// This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) 
		//	or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. 
		// Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, 
		//	and store enough application state information to restore your application 
		//	to its current state in case it is terminated later.
		// If your application supports background execution, this method is called 
		//	instead of applicationWillTerminate: when the user quits.
		// TODO: core data
		#if !TARGET_INTERFACE_BUILDER
		if !isTestProject {
			applicationClose(application: application)
		}
		#endif
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; 
		//	here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. 
		// If the application was previously in the background, optionally refresh the user interface.
		#if !TARGET_INTERFACE_BUILDER
		if !isTestProject {
			applicationOpen(application: application)
		}
		#endif
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. 
		// See also applicationDidEnterBackground:

		// Saves changes in the application's managed object context before the application terminates.
		#if !TARGET_INTERFACE_BUILDER
		if !isTestProject {
			applicationClose(application: application)
		}
		#endif
	}

}

// MARK: MEGameTracker AppDelegate
extension AppDelegate {
	func applicationOpen(application: UIApplication) {
		guard isAppFirstOpen else {
			applicationReopen(application: application)
			return
		}

		// UI stuff
        Styles.current.initialize(fromWindow: window)
        Styles.current.isInitialized = true

		// start the chain to load core data and cloud data and init the ME App:
		initializeData(application: application)

		// set up a listener to the show-an-alert signal
		Alert.onSignal.cancelSubscription(for: self)
		_ = Alert.onSignal.subscribe(with: self) { [weak self] (alert: Alert) in
			DispatchQueue.main.async {
				if let controller = self?.window?.rootViewController?.activeViewController {
					alert.show(fromController: controller)
				}
			}
		}
	}

	func applicationReopen(application: UIApplication) {
		guard isClosedApp else { return }
		isClosedApp = false
		// we invalidated timer when we closed, so recreate it
		setupCloudKitTimer()
	}

	func applicationClose(application: UIApplication) {
		guard !isClosedApp else { return }

		var backgroundTask: UIBackgroundTaskIdentifier?

		let guaranteedActions: (() -> Void) = {
			// mark the app as having been opened so we don't repeat our init stuff
			UserDefaults.standard.synchronize()
			self.isAppFirstOpen = false
			self.isClosedApp = true
			// close app
			if let backgroundTask = backgroundTask,
                backgroundTask.rawValue != convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid) {
				application.endBackgroundTask(backgroundTask)
			}
			backgroundTask = UIBackgroundTaskIdentifier(rawValue: convertFromUIBackgroundTaskIdentifier(UIBackgroundTaskIdentifier.invalid))
		}

		backgroundTask = application.beginBackgroundTask {
			guaranteedActions()
		}

		// code to execute before exiting app ...

		self.cloudSyncTimer?.invalidate()
		self.appSaveTimer?.invalidate()
		App.current.store() // do before cloud to get any pending changes
		GamesDataBackup.current.sync(appState: .stop)
		CoreDataManager.current.save()
		guaranteedActions()
	}
}

// MARK: All megametracker:// Initialization
extension AppDelegate {

	func initializeData(application: UIApplication) {

		// currently this all runs on the main thead 
		//   because we must have each step completed before we move on to the next.

		// Show spinner to player
		let spinner = Spinner(title: "Initializing Data", isShowProgress: true)
		if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController  {
			// USE TOP WINDOW AND MAIN THREAD - BLOCK ALL OTHER ACTIONS UNTIL WE ARE DONE!
			spinner.show(from: root.view, animated: true) {}
		}

		let spinnerUpdateProgressBlock: ((Int) -> Void) = { (progress: Int) in
			DispatchQueue.main.async {
				spinner.updateProgress(percentCompleted: progress)
			}
		}

		// Initialize core data
		initializeCoreData(
			application: application,
			spinnerUpdateProgressBlock: spinnerUpdateProgressBlock
		) { [weak self] in

			// Hide migration progress bar
			DispatchQueue.main.async {
				spinner.changeIsShowProgress(false)
			}

			// Any code requiring base data must go after here.

			// change spinner message
			DispatchQueue.main.async {
				spinner.changeMessage("Checking Cloud")
			}

			// Start cloud subscriptions and download any cloud data.
			// (This is blocking because we don't want to start a new shepard if we have a shepard in the cloud.)
			self?.initializeCloudKit(application: application) { [weak self] in

				// change spinner message
				DispatchQueue.main.async {
					spinner.changeMessage("Initializing App")
				}

				// initialize app
				self?.initializeApp {
					// App is now safe to use

					// get rid of spinner
					DispatchQueue.main.async {
						spinner.dismiss(animated: true) {}
					}
				}
			}
		}
	}
}

// MARK: megametracker:// CoreData Initialization
extension AppDelegate {

	func initializeCoreData(
		application: UIApplication,
		spinnerUpdateProgressBlock: @escaping ((Int) -> Void) = { _ in },
		completion: @escaping (() -> Void) = {}
	) {

		// Subscribe to migration progress
		CoreDataMigrations.onPercentProgress.cancelSubscription(for: self)
		_ = CoreDataMigrations.onPercentProgress.subscribe(with: self) { (progress: Int) in
			spinnerUpdateProgressBlock(progress)
		}

		// Run any migrations
		DispatchQueue.global(qos: .background).async {
			try? CoreDataMigrationManager().migrateFrom(
				lastBuild: App.current.lastBuild
			) { [weak self] in
				// base data is loaded as of now
				if let me = self {
					CoreDataMigrations.onPercentProgress.cancelSubscription(for: me)
				}
				completion()
			}
		}
	}
}

// MARK: megametracker:// CloudKit Initialization
extension AppDelegate {

	func initializeCloudKit(
		application: UIApplication,
		completion: @escaping (() -> Void) = {}
	) {
		GamesDataBackup.current.sync(
				appState: .start,
				qualityOfService: .userInitiated
			) { [weak self] _ in // isSynced: Bool
			// data is fully loaded as of now
			GamesDataBackup.current.subscribeAccountChanges()
			GamesDataBackup.current.subscribeDataChanges()
            DispatchQueue.main.async { application.registerForRemoteNotifications() }
			// schedule periodic cloudkit sync
			self?.setupCloudKitTimer()
			completion()
		}

	}

	func setupCloudKitTimer() {
		DispatchQueue.main.async { [weak self] in // MAIN necessary for timer
			self?.cloudSyncTimer?.invalidate()
			let interval = GamesDataBackup.current.postChangeWaitIntervalSeconds
			self?.cloudSyncTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
			   GamesDataBackup.current.sync(isPartialPost: true) // only runs if actual change waiting
			}
			self?.cloudSyncTimer?.tolerance = interval // we aren't that picky about when this runs
		}
	}
}

// MARK: megametracker:// App Initialization
extension AppDelegate {

	func initializeApp(
		completion: @escaping (() -> Void) = {}
	) {
		App.retrieve {
			// app and data are fully loaded as of now
			setupAppSaveTimer()
			completion()
		}
	}

	func setupAppSaveTimer() {
		DispatchQueue.main.async { [weak self] in // MAIN necessary for timer
			self?.appSaveTimer?.invalidate()
			let interval = App.current.postChangeWaitIntervalSeconds
			self?.appSaveTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
				_ = App.current.saveAnyChanges(isAllowDelay: false)
			}
			self?.appSaveTimer?.tolerance = interval // we aren't that picky about when this runs
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIBackgroundTaskIdentifier(_ input: UIBackgroundTaskIdentifier) -> Int {
	return input.rawValue
}
