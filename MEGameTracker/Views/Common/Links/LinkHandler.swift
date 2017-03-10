//
//  LinkHandler.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/14/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit
import SafariServices

public typealias StoryboardIdentifier = (name: String, scene: String?)
public typealias ConfigureViewController = ((UIViewController) -> Void)

public class LinkHandler: NSObject, SFSafariViewControllerDelegate {

	internal weak var source: Linkable?
	internal weak var originController: UIViewController?

	// TODO: we may need to save last click position for popover placement

	public override init() {}

	public init(controller: UIViewController?) {
		originController = controller
	}

	public func openURL(_ url: URL, source: Linkable) {
		self.source = source
		originController = source.originController
		DispatchQueue.main.async {
			(self.originController as? Spinnerable)?.startSpinner(inView: self.originController?.view)
		}
		DispatchQueue.global(qos: .background).async {
			if self.isInternalUrl(url) {
				self.redirectInternalUrl(url)
				DispatchQueue.main.async {
					(self.originController as? Spinnerable)?.stopSpinner(inView: self.originController?.view)
				}
			} else {
				let controller = SFSafariViewController(url: url)
				controller.delegate = self
				DispatchQueue.main.async {
					self.originController?.present(controller, animated: true, completion: nil)
					(self.originController as? Spinnerable)?.stopSpinner(inView: self.originController?.view)
				}
			}
		}
	}

	fileprivate func isInternalUrl(_ url: URL) -> Bool {
		return url.scheme == "megametracker"
	}

	fileprivate func redirectInternalUrl(_ url: URL) {
		let page = url.host ?? ""
		let parameters = url.queryDictionary
		switch page {
		case "person": redirectPerson(parameters: parameters)
		case "item": redirectItem(parameters: parameters)
		case "map": redirectMap(parameters: parameters)
		case "maplocation": redirectMapLocationable(parameters: parameters)
		case "maplocation": redirectMapLocationable(parameters: parameters) // TODO: figure out why it does this ?!?
		case "mission": redirectMission(parameters: parameters)
		default: break
		}
	}

	/// [Matriarch Benezia|megametracker://person?name=Matriarch%20Benezia]
	fileprivate func redirectPerson(parameters: [String: String]) {
		let alwaysDeepLink = parameters["alwaysdeeplink"] == "1"
		guard let person = parameters["id"] != nil ?
					Person.get(id: parameters["id"] ?? "0", gameVersion: App.current.gameVersion) :
					Person.get(name: parameters["name"] ?? "N/A", gameVersion: App.current.gameVersion)
		else {
			// error
			return
		}
		if !alwaysDeepLink &&
			(originController?.tabBarController?.selectedIndex == MEMainTab.group.rawValue
				|| (originController as? UITabBarController)?.selectedIndex == MEMainTab.group.rawValue) {
			// we are in persons, so just push or we will lose our spot

			DispatchQueue.main.async {
				// pop controllers to top level
				if let originController = self.originController, originController.presentedViewController != nil {
						originController.dismiss(animated: false, completion: nil)
				}
				if let controller = self.originController as? PersonController, controller.person == person {
					return // do nothing, here already
				}

				self.pushStoryboard(StoryboardIdentifier(name: "GroupFlow", scene: "Person")) { destinationController in
					destinationController.find(controllerType: PersonController.self) { controller in
						controller.person = person
					}
				}
			}
		} else {
			// go to persons tab and load up person, deep link style
			switchToLinkableTab(.group, toControllerType: GroupSplitViewController.self) { controller in
				(controller as? GroupSplitViewController)?.deepLink(person, type: "Person")
			}
		}
		// I also need a new link type that specifies popover = true, 
		//	for stuff I really just want to popover (like short messages).
	}

	/// [Galaxy Map|megametracker://map?id=1]
	fileprivate func redirectMap(parameters: [String: String]) {
		let alwaysDeepLink = parameters["alwaysdeeplink"] == "1"
		if let mapId = parameters["id"], let map = Map.get(id: mapId) {
			if !alwaysDeepLink && originController?.tabBarController?.selectedIndex == MEMainTab.maps.rawValue {

				DispatchQueue.main.async {
					// pop controllers to top level
					if let originController = self.originController, originController.presentedViewController != nil {
							originController.dismiss(animated: false, completion: nil)
					}
					if let controller = self.originController as? MapController, controller.map == map {
						return // do nothing, here already
					}

					self.pushStoryboard(StoryboardIdentifier(name: "MapsFlow", scene: "Map")) { destinationController in
						destinationController.find(controllerType: MapController.self) { controller in
							controller.map = map
						}
					}
				}
			} else {
				// go to maps tab and load up map, deep link style
				switchToLinkableTab(.maps, toControllerType: MapsController.self) { controller in
					(controller as? MapsController)?.deepLink(map, type: "Map")
				}
			}
		}
	}
	/// [Sovereign|megametracker://item?id=I1.X]
	fileprivate func redirectItem(parameters: [String: String]) {
		guard Item.get(id: parameters["id"] ?? "0") != nil else { return }
		// TODO
	}

	/// [Galaxy Map|megametracker://maplocation?id=1]
	fileprivate func redirectMapLocationable(parameters: [String: String]) {
		let alwaysDeepLink = parameters["alwaysdeeplink"] == "1"
		let gameVersion = GameVersion(rawValue: parameters["gameVersion"] ?? "") ?? App.current.gameVersion
		guard let id = parameters["id"],
			let mapLocation: MapLocationable = {
				var list: [String: SerializedDataStorable?] = [:]
				parameters.forEach { (k, v) in list[k] = v }
				let data = SerializableData.safeInit(list)
				if let type = MapLocationType(stringValue: parameters["type"] ?? ""),
				   let mapLocation = MapLocation.get(id: id, type: type, gameVersion: gameVersion) {
					if var map = mapLocation as? Map {
						map.generalData.isHidden = false // force  to be visible
						return map
					}
					return mapLocation
				} else if
					let name = data["title"]?.string,
					let mapLocationCoords = data["location"]?.string?.characters.split(separator: "x").map(String.init),
					let mapLocationX = Double(mapLocationCoords[0]),
					let mapLocationY = Double(mapLocationCoords[1]) {
					let mapLocationRadius = data["radius"]?.double ?? 1.0
					list = [:]
					list["id"] = "\(id).detail"
					list["name"] = name
					if var dataMap = DataMap(data: SerializableData.safeInit(list)) {
						dataMap.mapLocationPoint = MapLocationPoint(
							x: CGFloat(mapLocationX),
							y: CGFloat(mapLocationY),
							radius: CGFloat(mapLocationRadius)
						)
						dataMap.inMapId = id
						dataMap.isOpensDetail = false
						return Map(id: dataMap.id, gameVersion: App.current.gameVersion, generalData: dataMap)
					}
				}
				return nil
			}()
		else {
			// error
			return
		}

		if !alwaysDeepLink && originController?.tabBarController?.selectedIndex == MEMainTab.maps.rawValue,
		   let mapId = mapLocation.inMapId,
		   let map = Map.get(id: mapId, gameVersion: gameVersion) {

			DispatchQueue.main.async {
				// pop controllers to top level
				if let originController = self.originController, originController.presentedViewController != nil {
						originController.dismiss(animated: false, completion: nil)
				}
				if let controller = self.originController as? MapController,
					controller.map == map && controller.self.mapLocation?.isEqual(mapLocation) == true {
					return // do nothing, here already
				}

				self.pushStoryboard(StoryboardIdentifier(name: "MapsFlow", scene: "Map")) { destinationController in
					destinationController.find(controllerType: MapController.self) { controller in
						controller.map = map
						controller.mapLocation = mapLocation
					}
				}
			}
		} else {
			// go to maps tab and load up map, deep link style
			switchToLinkableTab(.maps, toControllerType: MapsController.self) { controller in
				(controller as? DeepLinkable)?.deepLink(mapLocation as? DeepLinkType, type: "MapLocationable")
			}
		}
	}

	/// [Prologue|megametracker://mission?id=M1.Prologue]
	fileprivate func redirectMission(parameters: [String: String]) {
		let alwaysDeepLink = parameters["alwaysdeeplink"] == "1"
		guard let id = parameters["id"],
				  let mission = Mission.get(id: id)
		else {
			// error
			return
		}
		if !alwaysDeepLink && originController?.tabBarController?.selectedIndex == MEMainTab.missions.rawValue {
			// we are in missions, so just push or we will lose our spot

			DispatchQueue.main.async {
				// pop controllers to top level
				if let originController = self.originController,
					originController.presentedViewController != nil {
					originController.dismiss(animated: false, completion: nil)
				}
				if let controller = self.originController as? MissionController, controller.mission == mission {
					return // do nothing, here already
				}

				self.pushStoryboard(
					StoryboardIdentifier(name: "MissionsFlow", scene: "Mission")
				) { destinationController in
					destinationController.find(controllerType: MissionController.self) { controller in
						controller.mission = mission
					}
				}
			}
		} else {
			// go to maps tab and load up map, deep link style
			switchToLinkableTab(.missions, toControllerType: MissionsGroupsController.self) { controller in
				(controller as? DeepLinkable)?.deepLink(mission, type: "Mission")
			}
		}
	}

	internal var closeHandlers: [Int: (() -> Void)] = [:]
	public func closeModal(_ sender: UIBarButtonItem) {
		let key = sender.hashValue
		if let closure = closeHandlers[key] {
			closure()
			closeHandlers.removeValue(forKey: key)
		}
	}

	public func pushStoryboard(_ storyboard: StoryboardIdentifier, withClosure closure: ConfigureViewController) {
		let bundle = Bundle(for: type(of: self))
		let storyboardObj = UIStoryboard(name: storyboard.name, bundle: bundle)
		if let controller = (storyboard.scene != nil
				? storyboardObj.instantiateViewController(withIdentifier: storyboard.scene!)
				: storyboardObj.instantiateInitialViewController()) {
			closure(controller)
			DispatchQueue.main.async {
				self.originController?.navigationController?.pushViewController(controller, animated: true)
			}
		}
		// else error?
	}

	public func switchToLinkableTab<T: UIViewController>(
		_ tab: MEMainTab,
		toControllerType: T.Type,
		withClosure closure: @escaping ConfigureViewController
	) {
		// go to tab
		DispatchQueue.main.async {
			// note: if this is first visit to tab in question, this will trigger UI changes: 
			self.originController?.tabBarController?.selectedIndex = tab.rawValue
			guard let wrapperController = self.originController?.tabBarController?.selectedViewController
			else {
				return
				//error
			}

			let targetController = self.targetControllerFromWrapperController(wrapperController)
			var currentController = targetController

			// pop controllers to top level
			while currentController != nil && !(currentController is T) && currentController != wrapperController {
				_ = currentController?.navigationController?.popViewController(animated: false)
				currentController = self.targetControllerFromWrapperController(wrapperController)
			}

			// find the target controller
			if let targetController = targetController, let _ = targetController as? T {
				closure(targetController)
			} else {
				// pass on data for controller to deal with
				currentController?.find(controllerType: UIViewController.self) { destinationController in
					if let _ = destinationController as? T {
						closure(destinationController)
					}
				}
			}
		}
	}

	public func targetControllerFromWrapperController(_ wrapperController: UIViewController) -> UIViewController? {
		// pattern: tab -> [flow wrapper] (we come in here) -> navi -> flow wrapper -> controller
		if let controller2 = wrapperController as? UINavigationController {
			if let controller3 = controller2.visibleViewController { // [tab-specific kind] flow controller
				if let controller4 = controller3.childViewControllers.first { // actual scene view controller
					return controller4
				}
			}
		}
		return nil
	}

	// MARK: SFSafariViewControllerDelegate

	public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
