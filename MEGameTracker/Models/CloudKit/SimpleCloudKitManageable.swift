//
//  SimpleCloudKitManageable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/6/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit
import CloudKit

// swiftlint:disable file_length
// TODO: Split out to smaller size?

public enum AppStateForCloud {
	case start, stop, running
}

/// Note: we need a reference object because we pass things in closures and data would be lost with value type.
/// At some point, I can try retooling so every closure returns self as first parameter, but ... not right now.
public protocol SimpleCloudKitManageable: class, SimpleCloudKitManageableConforming {
	/// Future note if I implement as value-type again: 
	///   this property must be Self type, or properties specific to this object are lost
	///   during handoff between SimpleCloudKitManageable and GamesDataBackup,
	///   resulting in a bad access error.
	static var current: SimpleCloudKitManageable { get set }
	// MARK: customizable
	var isLog: Bool { get }
	var postChangeWaitIntervalSeconds: TimeInterval { get } // 10 minutes = 60 * 10
	var subscriptionId: String { get }
	var zoneName: String { get }
	var container: CKContainer { get }
	func saveOneFromCloud(
		record: CKRecord,
		completion: @escaping ((Bool) -> Void)
	)
	func deleteOneFromCloud(
		recordId: CKRecord.ID,
		recordType: String,
		completion: @escaping ((Bool) -> Void)
	)
	func changesFromCloudCompletion(
		isSuccess: Bool,
		completion: @escaping ((Bool) -> Void)
	)
	func fetchSavesToCloud() -> [CKRecord]
	func fetchDeletesToCloud() -> [CKRecord.ID]
	func changesToCloudCompletion(
		isSuccess: Bool,
		savedRecords: [CKRecord],
		deletedRecordIds: [CKRecord.ID],
		completion: @escaping ((Bool) -> Void)
	)
	func resetLocalData(
		completion: @escaping ((Bool) -> Void)
	)
	func switchAccountAlert(
		replaceAction: @escaping ((UIAlertAction) -> Void),
		copyAction: @escaping ((UIAlertAction) -> Void)
	) -> Alert
	func notifyStartSyncing()
	func notifyStopSyncing()
	// MARK: transitory stored data
	var isPendingCloudChanges: Bool { get set }
	var qualityOfService: QualityOfService? { get set }
	var appState: AppStateForCloud { get set }
	var isSyncing: Bool { get set }
	var isFetchingChanges: Bool { get set }
	var isPostingChanges: Bool { get set }
	var isSubscribed: Bool { get set }
	var isAccountChangeSubscribed: Bool { get set }
	var isZoneInitialized: Bool { get set }
	var isAvailabilityChecked: Bool { get set }
	var accountStatus: CKAccountStatus { get set }
	var lastPostedDate: Date { get set }
	var cachedCloudImages: [String: UIImage] { get set }
	// MARK: permanent stored data - please make sure to use get/set observers to save these values somewhere
	var isUseCloud: Bool { get set }
	var isFirstSync: Bool { get set }
	var isCloudQuotaExceeded: Bool { get set }
	var accountName: String? { get set }
	var changeToken: CKServerChangeToken? { get set }
	// MARK: accessible functions
	func sync(
		appState: AppStateForCloud,
		isPartialPost: Bool,
		qualityOfService: QualityOfService?,
		completion: @escaping ((Bool) -> Void)
	)
	func shouldFetchChanges() -> Bool
	func fetchChanges(
		completion: @escaping ((Bool) -> Void)
	)
	func shouldPostChanges() -> Bool
	func postChanges(
		completion: @escaping ((Bool) -> Void)
	)
	func postChangeBatch(
		recordsToSave: [CKRecord],
		recordIDsToDelete: [CKRecord.ID],
		isRootRequest: Bool,
		batchCompletion: @escaping (([CKRecord]?, [CKRecord.ID]?) -> Void),
		finalCompletion: @escaping ((Bool) -> Void)
	)
	func checkAvailability(
		completion: @escaping ((Bool) -> Void)
	)
	func subscribeDataChanges(
		completion: @escaping ((Bool) -> Void)
	)
	func subscribeAccountChanges()
	func log(_ message: String)
}

extension SimpleCloudKitManageable {

	var privateDatabase: CKDatabase? {
		return container.privateCloudDatabase
	}
	var zoneId: CKRecordZone.ID {
		return CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
	}

	// MARK: customizable
	public var subscriptionId: String { return "Data" }
	public var zoneName: String { return "Data" }
	public func saveOneFromCloud(
		record: CKRecord,
		completion: @escaping ((Bool) -> Void)
	) {
		completion(true)
	}
	public func deleteOneFromCloud(
		recordId: CKRecord.ID,
		recordType: String,
		completion: @escaping ((Bool) -> Void)
	) { completion(true) }
	public func changesFromCloudCompletion(
		isSuccess: Bool,
		completion: @escaping ((Bool) -> Void)
	) {
		completion(true)
	}
	public func fetchSavesToCloud() -> [CKRecord] { return [] }
	public func fetchDeletesToCloud() -> [CKRecord.ID] { return [] }
	public func changesToCloudCompletion(
		isSuccess: Bool,
		savedRecords: [CKRecord],
		deletedRecordIds: [CKRecord.ID],
		completion: @escaping ((Bool) -> Void)
	) {
		completion(true)
	}
	public func resetLocalData(
		completion: @escaping ((Bool) -> Void)
	) {
		completion(true)
	}

	// MARK: permanent stored data
	public var isUseCloud: Bool { return true }
	public var isFirstSync: Bool { return true }
	public var isCloudQuotaExceeded: Bool { return false }
	public var accountName: String? { return nil }
	public var changeToken: CKServerChangeToken? { return nil }

	// MARK: available functions

	public func shouldSync() -> Bool {
		// reasoning: don't bother posting if:
		// - icloud was disabled
		// - we are stopping and have no changes
		// - already syncing
		log("shouldSync? isUseCloud = \(isUseCloud) appState = \(appState) " +
			"isPendingCloudChanges = \(isPendingCloudChanges) isSyncing = \(isSyncing)")
		return isUseCloud
			&& !(appState == .stop && !isPendingCloudChanges)
			&& !isSyncing
	}

	/// Called by interval timer
	public func sync(
		isPartialPost: Bool
	) {
		sync(
			appState: self.appState,
			isPartialPost: isPartialPost,
			qualityOfService: nil,
			completion: { _ in }
		)
	}

	/// Called by anything w/o appState, isPartialPost or qualityOfService specified
	public func sync(
		appState: AppStateForCloud? = nil,
		qualityOfService: QualityOfService? = nil,
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		sync(
			appState: appState ?? self.appState,
			isPartialPost: false,
			qualityOfService: qualityOfService,
			completion: completion
		)
	}
	public func sync(
		appState: AppStateForCloud,
		isPartialPost: Bool,
		qualityOfService: QualityOfService?,
		completion: @escaping ((Bool) -> Void)
	) {
		self.appState = appState
		let oldQualityOfService = self.qualityOfService
		self.qualityOfService = qualityOfService
		guard shouldSync() else { completion(false); return }
		log("""
            Starting sync() appState = \(appState) isPartialPost = \(isPartialPost)
            qualityOfService = \(String(describing: qualityOfService))
            oldQualityOfService = \(String(describing: oldQualityOfService))
        """)
		isSyncing = true
		cachedCloudImages = [:]
		let partCompletion: ((Bool) -> Void) = { (isSynced: Bool) in
			self.log("partCompletion isSynced = \(isSynced)")
			self.isSyncing = false
			self.qualityOfService = oldQualityOfService
			self.notifyStopSyncing()
			completion(isSynced)
		}
		let successCompletion: ((Bool) -> Void) = { (isSynced: Bool) in
			self.log("successCompletion isSynced = \(isSynced)")
			self.appState = .running
			self.isFirstSync = false
			partCompletion(isSynced)
		}
		checkAvailability { isAvailable in
			self.log("checkAvailability isAvailable = \(isAvailable)")
			if isAvailable { // checks more than account status
				self.initializeRecordZone { hasInitializedZone in
					self.log("initializeRecordZone hasInitializedZone = \(hasInitializedZone)")
					self.notifyStartSyncing()
					guard hasInitializedZone else {
						partCompletion(false)
						return
					}
					if !isPartialPost || self.appState == .start {
						// complete sync (second condition above is if internet was disabled at app open)
						if self.isFirstSync {
							self.firstTimeSync(completion: successCompletion)
						} else {
							self.subsequentSync(completion: successCompletion)
						}
					} else {
						// Don't ever run partial post before .start state
						if self.appState == .running {
							self.postChanges(completion: successCompletion)
						} else {
							partCompletion(false)
						}
					}
				}
			} else {
				partCompletion(false)
			}
		}
	}

	func firstTimeSync(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		log("firstTimeSync")
		// write all data to cloud (first time using cloud != first time using app)
		postChanges { isPosted in
			if isPosted {
				// get all data from cloud
				self.fetchChanges { isFetched in
					completion(isFetched)
				}
			} else {
				completion(false)
			}
		}
	}

	func subsequentSync(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		log("subsequentSync")
		// get all data from cloud
		fetchChanges { (isFetched: Bool) in
			if isFetched {
				// write all data to cloud
				self.postChanges { isPosted in
					completion(isPosted)
				}
			} else {
				completion(false)
			}
		}
	}

	public func shouldFetchChanges() -> Bool {
		// reasoning: don't bother posting i:
		// - icloud was disabled
		// - icloud is not working
		// - already fetching changes
		log("shouldFetchChanges? isUseCloud = \(isUseCloud) " +
			"accountStatus = \(accountStatus) isFetchingChanges = \(isFetchingChanges)")
		return isUseCloud
			&& accountStatus == .available
			&& !isFetchingChanges
//			&& appState != .stop // NO! this state is processed separately, so it doesn't block subsequent actions
	}

	public func fetchChanges() { fetchChanges { _ in } }

	// swiftlint:disable function_body_length
	public func fetchChanges(
		completion: @escaping ((Bool) -> Void)
	) {
		guard shouldFetchChanges() else { completion(false); return }
		log("fetchChanges changeToken = \(String(describing: changeToken))")

		isFetchingChanges = true
		var resetIsSyncingProperty: Bool = false
		if !isSyncing {
			resetIsSyncingProperty = true
			self.isSyncing = true
		}

		let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
		options.previousServerChangeToken = changeToken
		let operation = CKFetchRecordZoneChangesOperation(
			recordZoneIDs: [zoneId],
			optionsByRecordZoneID: [zoneId: options]
		)
		operation.fetchAllChanges = true
		if let qos = qualityOfService {
			operation.qualityOfService = qos
		}

		var isFinished = false
		var isSuccess = true

		operation.recordChangedBlock = { (record: CKRecord) -> Void in
			self.saveOneFromCloud(record: record) { isQueued in
				isSuccess = isSuccess && isQueued
			}
		}

		operation.recordWithIDWasDeletedBlock = { (recordId: CKRecord.ID, recordType: String) -> Void in
			if !self.isFirstSync {
				// (we don't need to delete stuff if this is our first time fetching data)
				self.deleteOneFromCloud(recordId: recordId, recordType: recordType) { isQueued in
					isSuccess = isSuccess && isQueued
				}
			}
		}

		operation.recordZoneFetchCompletionBlock = { recordZoneId, changeToken, tokenData, isMoreComing, error in
			if let error = error {
				isFinished = true
				isSuccess = false
				print("Error recordZoneFetchCompletionBlock: \(error)")
				if (error as? CKError)?.code == CKError.changeTokenExpired {
					// start over with new token
					self.changeToken = nil
					self.fetchChanges(completion: completion)
				}
				return
			}
			if !isMoreComing {
				isFinished = true
				// isFetchingChanges is still true
				self.changesFromCloudCompletion(
					isSuccess: isSuccess
				) { isSaved in
					self.log("changesFromCloudCompletion isSuccess = \(isSuccess) changeToken = \(String(describing: changeToken))")
					if isSaved {
						self.changeToken = changeToken
					} else {
						isSuccess = false
					}
				}
			}
		}

		operation.completionBlock = {
			guard isFinished else { return }
			self.isFetchingChanges = false
			if resetIsSyncingProperty {
				self.isSyncing = false
			}
			completion(isFinished)//isSuccess)
			// ignore local save from cloud failures for now - proceed to saving local changes to cloud
		}

		privateDatabase?.add(operation)
	}
	// swiftlint:enable function_body_length

	public func shouldPostChanges() -> Bool {
		// reasoning: don't bother posting i:
		// - icloud was disabled
		// - icloud is not working
		// - icloud quota reached, and is not an app start request (ie, try again on next app start)
		// - not a start/stop sync, and we don't have any changes
		// - we have not waited for the specified time
		// - already posting changes
		log("shouldPostChanges? isUseCloud = \(isUseCloud) accountStatus = \(accountStatus) " +
			"appState = \(appState) isCloudQuotaExceeded = \(isCloudQuotaExceeded) " +
			"isPendingCloudChanges = \(isPendingCloudChanges) " +
			"time since lastPostedDate = \(Date().timeIntervalSince(lastPostedDate)) " +
			"postChangeWaitIntervalSeconds = \(postChangeWaitIntervalSeconds) isPostingChanges = \(isPostingChanges)")
		return isUseCloud
			&& accountStatus == .available
			&& !(appState == .running && isCloudQuotaExceeded)
			&& !(appState == .running && !isPendingCloudChanges)
			&& !(appState == .running && Date().timeIntervalSince(lastPostedDate) < postChangeWaitIntervalSeconds)
			&& !isPostingChanges
	}

	public func postChanges() { postChanges { _ in } }
	public func postChanges(
		completion: @escaping ((Bool) -> Void)
	) {
		guard shouldPostChanges() else { completion(false); return }
		log("postChanges changeToken =\(String(describing: changeToken))")

		isPostingChanges = true
		lastPostedDate = Date()
		var resetIsSyncingProperty: Bool = false
		if !isSyncing {
			resetIsSyncingProperty = true
			self.isSyncing = true
		}

		var isConfirmed = true

		let saveRecords = fetchSavesToCloud()
		let deleteRecordIds = fetchDeletesToCloud()

		let finalCompletion: ((Bool) -> Void) = { (isPosted: Bool) in
			self.isPostingChanges = false
			if resetIsSyncingProperty {
				self.isSyncing = false
			}
			if isPosted {
				// small risk that this was set to true by other process during sync, 
				// but that update will just be rolled into the next sync, so it's no big deal.
				self.isPendingCloudChanges = false
			}
			completion(isPosted && isConfirmed)
		}

		guard !(saveRecords.isEmpty && deleteRecordIds.isEmpty) else {
			finalCompletion(true)
			return
		}

		// we are sometimes asked to send smaller batches of updates, so be prepared for that:
		postChangeBatch(
			recordsToSave: saveRecords,
			recordIDsToDelete: deleteRecordIds,
			isRootRequest: true,
			batchCompletion: { ( savedRecords, deletedRecordIds) in
				self.changesToCloudCompletion(
					isSuccess: true,
					savedRecords: savedRecords ?? [],
					deletedRecordIds: deletedRecordIds ?? []
				) { (isSaved: Bool) in
					if isSaved {
						print("Saved set to cloud and confirmed changes")
					} else {
						isConfirmed = false
					}
				}
			},
			finalCompletion: finalCompletion
		)
	}

	public func postChangeBatch(
		recordsToSave: [CKRecord],
		recordIDsToDelete: [CKRecord.ID],
		isRootRequest: Bool,
		batchCompletion: @escaping (([CKRecord]?, [CKRecord.ID]?) -> Void),
		finalCompletion: @escaping ((Bool) -> Void)
	) {
		log("postChangeBatch recordsToSave = \(recordsToSave.count) " +
			"recordIDsToDelete = \(recordIDsToDelete.count) isRootRequest = \(isRootRequest)")

		let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
		operation.savePolicy = .changedKeys

		operation.modifyRecordsCompletionBlock = {
			(
				savedRecords: [CKRecord]?,
				deletedRecordIds: [CKRecord.ID]?,
				error: Error?
			) in
			if let error = error {
				if (error as? CKError)?.code == CKError.limitExceeded {
					self.processChangeBatchLimitExceeded(
						recordsToSave: recordsToSave,
						recordIDsToDelete: recordIDsToDelete,
						batchCompletion: batchCompletion,
						finalCompletion: finalCompletion
					)
					return
				}
				print("Failed to save to cloud: \(error)")
				if (error as? CKError)?.code == CKError.quotaExceeded {
					// start over with new token
					if !self.isCloudQuotaExceeded {
						self.isCloudQuotaExceeded = true
						let alert = Alert(
							title: "Cloud Quota Reached",
							description: "Information will continue storing locally, but cloud data will be limited."
						)
						DispatchQueue.main.async {
							Alert.onSignal.fire(alert)
						}
					}
					return
				}
				//TODO: serverRecordChanged - how to recover from this?
			}
			// success:
			self.isCloudQuotaExceeded = false
			batchCompletion(savedRecords, deletedRecordIds)
			if isRootRequest {
				finalCompletion(true)
			}
		}

		if let qos = qualityOfService {
			operation.qualityOfService = qos
		}

		privateDatabase?.add(operation)
	}

	internal func splitBatch<T>(original list: [T]) -> [[T]]? {
		log("splitBatch list = \(list.count)")
		if list.count >= 2 {
			let splitIndex: Int = list.count / 2
			return [ Array(list[0..<splitIndex]), Array(list[splitIndex..<list.count]) ]
		}
		return nil
	}

	internal func processChangeBatchLimitExceeded(
		recordsToSave: [CKRecord],
		recordIDsToDelete: [CKRecord.ID],
		batchCompletion: @escaping (([CKRecord]?, [CKRecord.ID]?) -> Void),
		finalCompletion: @escaping ((Bool) -> Void)
	) {
		log("processChangeBatchLimitExceeded recordsToSave = \(recordsToSave.count) " +
			"recordIDsToDelete = \(recordIDsToDelete.count)")

		// subdivide into batches and send bit by bit
		var saveBatches: [[CKRecord]] = []
		var deleteBatches: [[CKRecord.ID]] = []
		var isDivided = false
		if let batches = splitBatch(original: recordsToSave) {
			saveBatches = batches
			isDivided = true
		} else {
			saveBatches = [recordsToSave, []] // can't be subdivided anymore
		}
		if let batches = splitBatch(original: recordIDsToDelete) {
			deleteBatches = batches
			isDivided = true
		} else {
			deleteBatches = [recordIDsToDelete, []] // can't be subdivided anymore
		}
		if isDivided {
			self.postChangeBatch(
				recordsToSave: saveBatches[0],
				recordIDsToDelete: deleteBatches[0],
				isRootRequest: false,
				batchCompletion: batchCompletion,
				finalCompletion: { (isPosted: Bool) in
					if isPosted {
						self.postChangeBatch(
							recordsToSave: saveBatches[1],
							recordIDsToDelete: deleteBatches[1],
							isRootRequest: false,
							batchCompletion: batchCompletion,
							finalCompletion: finalCompletion
						)
					} else {
						finalCompletion(false)
					}
				}
			)
		} else {
			finalCompletion(false)
			return
		}

	}

	/// Creates the recordZone named in **subscriptionZoneId** if needed.
	/// If zone already exists, no error is reported.
	/// If we have already checked and found zone, does not run.
	///
	/// - Parameter completion: code to execute when done. Always runs.
	func initializeRecordZone(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		guard !isZoneInitialized else { completion(true); return }
		log("initializeRecordZone zoneId = \(zoneId.zoneName)")
		let subscriptionZone = CKRecordZone(zoneID: zoneId)
		let operation = CKModifyRecordZonesOperation(
			recordZonesToSave: [subscriptionZone],
			recordZoneIDsToDelete: nil
		)
		operation.modifyRecordZonesCompletionBlock = {
			(
				savedRecordZones: [CKRecordZone]?,
				deletedRecordZoneIDs: [CKRecordZone.ID]?,
				error: Error?
			) in
			if let error = error {
				print("Error creating recordZone \(error)")
			} else {
				self.log("... initialized")
				self.isZoneInitialized = true
			}
		}

		operation.completionBlock = {
			completion(self.isZoneInitialized)
		}

//		if let qos = qualityOfService {
//			operation.qualityOfService = qos
//		}

		operation.qualityOfService = .userInitiated // warning: this never times out at lower priorities

		privateDatabase?.add(operation)
	}

	///
	public func checkAvailability(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		guard isUseCloud && !isAvailabilityChecked else {
			completion(accountStatus == .available)
			return
		}
		log("checkAvailability")
		isAvailabilityChecked = true
		container.accountStatus { (status, error) in
			self.accountStatus = status
			self.log("status = \(status)")
			if status == .available {
				// check user account
				self.container.fetchUserRecordID { (recordId, error) in
					self.log("recordId = \(recordId?.recordName ?? "")")
					if let error = error {
						print("Error retrieving user account: \(error)")
						self.accountStatus = .noAccount // sorry, no account. Stop cloud stuff.
						completion(false)
					} else {
						self.compareAccount(recordId: recordId, completion: completion)
					}
				}
			} else {
				if !self.isFirstSync
					&& self.accountName != nil {
					// alert customer that changes won't be synced ?
				}
				if status == CKAccountStatus.couldNotDetermine {
					// network failure or something
					// try again
					self.isAvailabilityChecked = false
				} else { // restricted, noAccount
					// don't delete old accountName: only make a change if/when cloud comes back.
				}
				completion(false)
			}
		}
	}

	func compareAccount(
		recordId: CKRecord.ID?,
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		guard let currentAccount = recordId?.recordName else { completion(true); return }
		log("compareAccount")
		accountStatus = .available
		let oldAccount = accountName
		if oldAccount?.isEmpty ?? true || isFirstSync {
			accountName = currentAccount
			completion(true)
		} else if currentAccount != oldAccount {
			switchAccount(account: currentAccount, completion: completion)
		} else {
			completion(true)
		}
	}

	func switchAccount(
		account: String,
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		log("switchAccount account = \(account)")
		// reset everything:
		isFirstSync = true
		appState = .start
		isZoneInitialized = false
		isCloudQuotaExceeded = false
		changeToken = nil
		accountName = account
		let alert = switchAccountAlert(replaceAction: { _ in
			self.resetForNewCloudData(completion: completion)
		}, copyAction: { _ in
			completion(true)
		})
		DispatchQueue.main.async {
			Alert.onSignal.fire(alert)
		}
	}

	public func switchAccountAlert(
		replaceAction: @escaping ((UIAlertAction) -> Void),
		copyAction: @escaping ((UIAlertAction) -> Void)
	) -> Alert {
		var alert = Alert(
			title: "Cloud Account Changed",
			description: "The games saved to this device belong to another cloud account. " +
				"What do you want to do? Copy everything over to the new cloud account, " +
				"or replace everything with the new cloud account (data may be lost)?"
		)
		alert.actions.append(Alert.ActionButtonType(title: "Replace", style: .destructive, handler: replaceAction))
		alert.actions.append(Alert.ActionButtonType(title: "Copy", style: .default, handler: copyAction))

		return alert
	}

	func resetForNewCloudData(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		log("resetForNewCloudData")
		resetLocalData { (isReset: Bool) in
			if isReset {
				self.isFirstSync = true
			}
			completion(isReset)
		}
	}

	func mergeData(
		completion: @escaping ((Bool) -> Void) = { _ in }
	) {
		log("mergeData")
		sync(appState: appState, completion: completion)
	}

	/// Subscribes to cloud recordZone any changes to data.
	/// If we have already subscribed and succeeded, does not run.
	///
	/// - Parameter completion: code to execute when done. Always runs.
	public func subscribeDataChanges() {
		subscribeDataChanges { _ in }
	}
	public func subscribeDataChanges(
		completion: @escaping ((Bool) -> Void)
	) {
		// add syncCloud() to appDelegate listener
		guard isUseCloud && !isSubscribed && accountStatus == .available else {
			completion(false)
			return
		}
		log("subscribeDataChanges")
		let subscription = CKDatabaseSubscription(subscriptionID: subscriptionId)
		let notificationInfo = CKSubscription.NotificationInfo()
		notificationInfo.shouldSendContentAvailable = true
		subscription.notificationInfo = notificationInfo
		let operation = CKModifySubscriptionsOperation(
		   subscriptionsToSave: [subscription], subscriptionIDsToDelete: []
		)
		operation.modifySubscriptionsCompletionBlock = {
			(
				savedSubscriptions: [CKSubscription]?,
				deletedSubscriptionIds: [String]?,
				error: Error?
			) in
			if let error = error {
				self.isSubscribed = false
				print("Error in modifySubscriptionsCompletionBlock \(error)")
			} else {
				self.isSubscribed = true
			}
		}

		operation.completionBlock = { completion(true) }

		operation.qualityOfService = .utility

		privateDatabase?.add(operation)
	}

	public func subscribeAccountChanges() {
		guard isUseCloud && !isAccountChangeSubscribed else {
			return
		}
		log("subscribeAccountChanges")
		NotificationCenter.default.addObserver(
			forName: NSNotification.Name.CKAccountChanged,
			object: nil,
			queue: nil
		) { _ in // notification
			self.isAvailabilityChecked = false
			self.sync()
		}
	}

	public func cacheImage(_ image: UIImage, recordId: String, key: String) {
		let imageKey = "\(recordId)||\(key)"
		log("cacheImage imageKey = \(imageKey)")
		cachedCloudImages[imageKey] = image
	}
	public func getCachedImage(recordId: String, key: String) -> UIImage? {
		let imageKey = "\(recordId)||\(key)"
		log("getCachedImage imageKey = \(imageKey)")
		if let image = cachedCloudImages[imageKey] {
			cachedCloudImages.removeValue(forKey: imageKey)
			return image
		}
		return nil
	}

	public func notifyStartSyncing() {
		// send notification?
		log("notifyStartSyncing")
	}
	public func notifyStopSyncing() {
		// send notification?
		log("notifyStopSyncing")
	}

	public func log(_ message: String) {
		if isLog {
			print(message)
		}
	}
}

public protocol SimpleCloudKitManageableConforming {
	var isPendingCloudChanges: Bool { get set }
	func log(_ message: String)
}
// swiftlint:enable file_length
