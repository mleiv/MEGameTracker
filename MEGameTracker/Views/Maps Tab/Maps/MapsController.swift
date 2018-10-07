//
//  MapsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
// TODO: Refactor

final public class MapsController: UITableViewController, Spinnerable {

	@IBOutlet weak var tempSearchBar: UISearchBar!
	var searchManager: MESearchManager?
	var currentSearchTimestamp: Date?

	// loaded dynamically
	var maps: [MapsSection: [Map]] = [:]
	var searchedMapLocations: [MapLocationType: [MapLocationable]] = [:]

	var pageLoaded = false
	var isUpdating = true

	var segueMap: Map?
	var segueMapLocationable: MapLocationable?

	var deepLinkedMap: Map?
	var deepLinkedMapLocationable: MapLocationable?

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
		pageLoaded = true
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.startListeners()
		}
		DispatchQueue.main.async { [weak self] in
			if self?.deepLinkedMap != nil {
				self?.startSpinner(inView: self?.view.superview)
			}
		}
	}

	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func setup(reloadData: Bool = false) {
		isUpdating = true
		tableView.allowsMultipleSelectionDuringEditing = false
		setupTableCustomCells()
		setupMaps()
		setupSearch()
		isUpdating = false
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.deepLink(self?.deepLinkedMap)
		}
	}

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "MapRow", bundle: bundle), forCellReuseIdentifier: "MapRow")
	}

	func dummyData() {
		// swiftlint:disable line_length
		maps = [.main: [], .recent: []]
		let map1 = Map.getDummy(json: "{\"id\": 8,\"name\": \"Normandy\",\"description\": \"None\",\"gameVersion\": 2,\"sortIndex\": 1,\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Normandy\\\"]\"}")
		let map2 = Map.getDummy(json: "{\"id\": 1,\"name\": \"Galaxy\",\"description\": \"None\",\"gameVersion\": null,\"sortIndex\": 0,\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Galaxy\\\"]\",\"imageName\":\"Galaxy\"}")
		maps[.main] = [map1, map2].compactMap { $0 }
		let oneDayAgo = Date(timeIntervalSinceNow: TimeInterval(24 * 60 * 60) * -1)
		var map3 = Map.getDummy(json: "{\"id\": 10,\"name\": \"Omega\",\"description\": \"None\",\"gameVersion\": 2,\"breadcrumbs\": [{\"id\": 1,\"name\": \"Galaxy\"},{\"id\": 2,\"name\": \"Omega Nebula\"},{\"id\": 3,\"name\": \"Sahrabarik\"}],\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Omega\\\"]\"}")
		map3?.modifiedDate = oneDayAgo
		var map4 = Map.getDummy(json: "{\"id\": 11,\"name\": \"Dossier: The Professor\",\"description\": \"None\",\"gameVersion\": 2,\"breadcrumbs\": [{\"id\": 1,\"name\": \"Galaxy\"},{\"id\": 2,\"name\": \"Omega Nebula\"},{\"id\": 3,\"name\": \"Sahrabarik\"},{\"id\": 10,\"name\": \"Omega\"}],\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Omega\\\"]\"}")
		map4?.modifiedDate = Date()
		maps[.recent] = [map3, map4].compactMap { $0 }
		// swiftlint:enable line_length
	}

	func searchedMapLocationsTypeBySection(_ section: Int) -> MapLocationType? {
		let sections = Array(searchedMapLocations.keys)
		let sortedSections = sections.sorted { $0.rawValue < $1.rawValue }
		return sortedSections.indices.contains(section) ? sortedSections[section] : nil
	}

	func setupMaps() {
		if UIWindow.isInterfaceBuilder {
			dummyData()
		} else {
			maps[.main] = Map.getAllMain().sorted(by: MapLocation.sort)
			maps[.recent] = Map.getAllRecent()
		}
	}

	func setupMapRow(_ indexPath: IndexPath, cell: MapRow) {
		guard let section = MapsSection(rawValue: (indexPath as NSIndexPath).section),
			  let maps = maps[section]
		else {
			return
		}
		if (indexPath as NSIndexPath).row < maps.count {
			_ = cell.define(
				map: maps[(indexPath as NSIndexPath).row],
				origin: self,
				isCalloutBoxRow: false,
				allowsSegue: true,
				isShowParentMapIfFound: true
			)
		}
	}

	func setupMapCalloutRow(_ indexPath: IndexPath, cell: MapRow) {
		if (indexPath as NSIndexPath).row < searchedMapLocations[.map]?.count ?? 0,
			let callout = searchedMapLocations[.map]?[(indexPath as NSIndexPath).row] as? Map {
			_ = cell.define(
				map: callout,
				origin: self,
				isCalloutBoxRow: false,
				allowsSegue: true,
				isShowParentMapIfFound: true
			)
		}
	}

	func setupMissionCalloutRow(_ indexPath: IndexPath, cell: MissionRow) {
		if (indexPath as NSIndexPath).row < searchedMapLocations[.mission]?.count ?? 0,
			let callout = searchedMapLocations[.mission]?[(indexPath as NSIndexPath).row] as? Mission {
			_ = cell.define(mission: callout, origin: self)
		}
	}

	func setupItemCalloutRow(_ indexPath: IndexPath, cell: ItemRow) {
		if (indexPath as NSIndexPath).row < searchedMapLocations[.item]?.count ?? 0,
			let callout = searchedMapLocations[.item]?[(indexPath as NSIndexPath).row] as? Item {
			_ = cell.define(item: callout, origin: self)
		}
	}

	func reloadDataOnChange(_ x: Bool = false) {
		guard !isUpdating else { return }
		isUpdating = true
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		DispatchQueue.global(qos: .background).async {
			self.setupMaps()
			DispatchQueue.main.async {
				self.tableView.reloadData()
				self.stopSpinner(inView: self.view.superview)
				self.isUpdating = false
			}
		}
	}

//	func updateMapOnChange(_ map: Map) {
//		guard !isUpdating else { return }
//		for (section, maps) in self.maps {
//			if let index = maps.index(of: map) {
//				self.maps[section]?[index] = map
//			}
//		}
//		isUpdating = true
//		tableView.reloadData()
//		isUpdating = false
//	}

	var shepardUuid = App.current.game?.shepard?.uuid
	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			reloadDataOnChange()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
		// listen for changes to recently viewed list
		App.onRecentlyViewedMapsChange.cancelSubscription(for: self)
		_ = App.onRecentlyViewedMapsChange.subscribe(on: self, callback: reloadDataOnChange)
		// listen for changes to maps data 
		Map.onChange.cancelSubscription(for: self)
		_ = Map.onChange.subscribe(on: self) { [weak self] changed in
			var reloadRows: [IndexPath] = []
			// can appear in both sections
			for type in (self?.maps ?? [:]).keys {
				if let index = self?.maps[type]?.index(where: { $0.id == changed.id }),
					let newMap = changed.object ?? Map.get(id: changed.id) {
					self?.maps[type]?[index] = newMap
					reloadRows.append(IndexPath(row: index, section: type.rawValue))
					break
				}
			}
			self?.reloadRows(reloadRows)
		}
		// decisions are loaded at detail page, don't have to listen
//			for key in (self?.searchedMapLocations ?? [:]).keys {
//				for (index, map) in (self?.searchedMapLocations[key] ?? []).enumerate() {
//					// TODO: protocol objects with events
//					if var map2 = map as? Mission {
//						map2.events = map2.events.map({ changedEvent == $0 ? changedEvent : $0 })
//						self?.searchedMapLocations[key]?[index] = map2
//					}

//					if var map2 = map as? Map {
//						map2.events = map2.events.map({ changedEvent == $0 ? changedEvent : $0 })
//						self?.searchedMapLocations[key]?[index] = map2
//					}

//				}

//			}
	}
}

extension MapsController {
	// MARK: Protocol - UITableViewDelegate

	enum MapsSection: Int {
		case main = 0, recent
	}

	override public func numberOfSections(in tableView: UITableView) -> Int {
		if tableView != self.tableView { // search
			return searchedMapLocations.keys.count
		} else {
			return 2
		}
	}

	override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView != self.tableView { // search
			let sections = searchedMapLocations.keys.compactMap { $0 }
			if sections.count <= 1 {
				return 0
			}
		}
		if section == 0 {
			return 30
		}
		return 15
	}

	override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView != self.tableView { // search
			if searchedMapLocations.keys.count <= 1 {
				return nil
			}
			let useSection = searchedMapLocationsTypeBySection(section) ?? .map
			switch useSection {
			case .map: return "Maps"
			case .mission: return "Missions"
			case .item: return "Items"
			}
		} else {
			switch section {
			case MapsSection.main.rawValue: return "Main Maps"
			case MapsSection.recent.rawValue: return "Recently Viewed"
			default: return nil
			}
		}
	}

	override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView != self.tableView { // search
			let useSection = searchedMapLocationsTypeBySection(section) ?? .map
			switch useSection {
			case .map: return searchedMapLocations[.map]?.count ?? 0
			case .mission: return searchedMapLocations[.mission]?.count ?? 0
			case .item: return searchedMapLocations[.item]?.count ?? 0
			}
		} else {
			switch section {
			case MapsSection.main.rawValue: return maps[MapsSection.main]?.count ?? 0
			case MapsSection.recent.rawValue: return maps[MapsSection.recent]?.count ?? 0
			default: return 0
			}
		}
	}

//	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return 1
//	}

	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView != self.tableView { // search
			let section = searchedMapLocationsTypeBySection((indexPath as NSIndexPath).section) ?? .map
			switch section {
			case .map:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "MapRow") as? MapRow {
					setupMapCalloutRow(indexPath, cell: cell)
					return cell
				}
			case .mission:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionRow") as? MissionRow {
					setupMissionCalloutRow(indexPath, cell: cell)
					return cell
				}
			case .item:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "ItemRow") as? ItemRow {
					setupItemCalloutRow(indexPath, cell: cell)
					return cell
				}
			}
			return super.tableView(tableView, cellForRowAt: indexPath)
		} else {
			if let cell = tableView.dequeueReusableCell(withIdentifier: "MapRow") as? MapRow {
				setupMapRow(indexPath, cell: cell)
				return cell
			}
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}

	override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
            let cell = tableView.cellForRow(at: indexPath)
            DispatchQueue.global(qos: .background).async {
                // use strong self (don't want to give up page until spinner is turned off)
                if tableView != self.tableView {
                let section = self.searchedMapLocationsTypeBySection((indexPath as NSIndexPath).section) ?? .map
                    if self.searchedMapLocations[section]?.indices.contains((indexPath as NSIndexPath).row) == true,
                       let mapLocation = self.searchedMapLocations[section]?[(indexPath as NSIndexPath).row],
                       let map = Map.get(id: mapLocation.inMapId ?? "") {
                        self.segueToMap(map, mapLocation: mapLocation, sender: cell)
                        return
                    }
                } else {
                    switch (indexPath as NSIndexPath).section {
                    case MapsSection.main.rawValue:
                        if self.maps[.main]?.indices.contains((indexPath as NSIndexPath).row) == true,
                           let map = self.maps[.main]?[(indexPath as NSIndexPath).row] {
                            self.segueToMap(map, sender: cell)
                            return
                        }
                    case MapsSection.recent.rawValue:
                        if self.maps[.recent]?.indices.contains((indexPath as NSIndexPath).row) == true,
                           let map = self.maps[.recent]?[(indexPath as NSIndexPath).row] {
                            self.segueToMap(map, sender: cell)
                            return
                        }
                    default: break
                    }
                }
                DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
                    self.stopSpinner(inView: self.view.superview)
                }
            }
        }
	}

	// MARK: Segues

	/// NOT OKAY! to call this from search. :(
	func selectMap(_ map: Map?, mapLocation: MapLocationable? = nil) -> Bool {
		guard let map = map else { return false }

//		let map2: Map? = {
//			return mapLocation?.isShowInParentMap == true ? Map.get(id: map.inMapId ?? "") : nil
//		}()
		let indexPath: IndexPath? = {
			if let index = maps[MapsSection.main]?.index(of: map) {
				return IndexPath(row: index, section: MapsSection.main.rawValue)
			} else if let index = maps[MapsSection.recent]?.index(of: map) {
				return IndexPath(row: index, section: MapsSection.recent.rawValue)
			}
			return nil
		}()
		DispatchQueue.main.async { [weak self] in
			var cell: UITableViewCell?
			if let indexPath = indexPath {
				cell = self?.tableView.cellForRow(at: indexPath)
			}
			self?.segueToMap(map, mapLocation: mapLocation, sender: cell)
		}
		return true
	}

	func segueToMap(_ map: Map?, mapLocation: MapLocationable? = nil, sender: AnyObject? = nil) {
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		DispatchQueue.global(qos: .background).async { // strong self (don't want to give up page until spinner is turned off)
			self.segueMap = map
			self.segueMapLocationable = mapLocation
			if mapLocation?.isShowInParentMap == true, let mapId = map?.inMapId, let map2 = Map.get(id: mapId) {
				self.segueMap = map2
				self.segueMapLocationable = map
			}
			DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
				self.parent?.performSegue(withIdentifier: "Show Map", sender: sender)
				self.stopSpinner(inView: self.view.superview)
			}
		}
	}

	override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		segue.destination.find(controllerType: MapSplitViewController.self) { controller in
			controller.map = self.segueMap
			controller.mapLocation = self.segueMapLocationable
			self.segueMap = nil
			self.segueMapLocationable = nil
		}
	}

}

extension MapsController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}

// MARK: MESearchManager
extension MapsController {

	/// Used for pages that want to open up just search content, no other maps.
	func startSearch(_ searchText: String) {
		let isInMapsTab = parent?.tabBarController?.selectedIndex == MEMainTab.maps.rawValue
		if !isInMapsTab {
			parent?.navigationItem.title = searchText
			tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
			tableView.tableHeaderView?.backgroundColor = UIColor.clear
		}
	}

	func setupSearch() {
		// create a separate results view:
		let resultsController = UITableViewController(style: .grouped)
		let bundle =  Bundle(for: type(of: self))
		resultsController.tableView?.register(UINib(nibName: "MapRow", bundle: bundle), forCellReuseIdentifier: "MapRow")
		resultsController.tableView?.register(
			UINib(nibName: "MissionRow", bundle: bundle),
			forCellReuseIdentifier: "MissionRow"
		)
		resultsController.tableView?.register(UINib(nibName: "ItemRow", bundle: bundle), forCellReuseIdentifier: "ItemRow")
		resultsController.tableView?.separatorStyle = .none
		resultsController.tableView?.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		resultsController.tableView?.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		resultsController.tableView?.dataSource = self
		resultsController.tableView?.delegate = self

		// set up search manager and bar:
		searchManager = MESearchManager(
			controller: self,
			tempSearchBar: tempSearchBar,
			resultsController: resultsController,
			searchData: searchMapLocations,
			closeSearch: closeSearch
		)
		tableView.tableHeaderView = searchManager?.searchController?.searchBar
		// (doesn't size right if we try to use a container view controlled by search manager)
	}

	func searchMapLocations(_ search: String? = nil) {
		searchedMapLocations = [:]
		guard search?.isEmpty == false else {
			stopSpinner(inView: tableView)
			return
		}
		startSpinner(inView: tableView)
		if !UIWindow.isInterfaceBuilder, let search = search {
			let currentSearchTimestamp = Date()
			self.currentSearchTimestamp = currentSearchTimestamp
			searchManager?.reloadData()
			DispatchQueue.global(qos: .background).async {
//				print("\n\nSearching: \(search)")
				let list1 = MapLocation.getAllMaps(
					likeName: search,
					limit: 30,
					gameVersion: App.current.gameVersion
				).sorted(by: MapLocation.sort)
				guard currentSearchTimestamp == self.currentSearchTimestamp
					  && self.searchManager?.showSearchData == true else { return }
				self.searchedMapLocations[.map] = list1
				let list2 = MapLocation.getAllMissions(
					likeName: search,
					limit: 30,
					gameVersion: App.current.gameVersion
				).filter({ $0.inMapId != nil }).sorted(by: MapLocation.sort)
				guard currentSearchTimestamp == self.currentSearchTimestamp
					  && self.searchManager?.showSearchData == true else { return }
				self.searchedMapLocations[.mission] = list2
				let list3 = MapLocation.getAllItems(
					likeName: search,
					limit: 30,
					gameVersion: App.current.gameVersion
				).sorted(by: MapLocation.sort)
				guard currentSearchTimestamp == self.currentSearchTimestamp
					  && self.searchManager?.showSearchData == true else { return }
				self.searchedMapLocations[.item] = list3
				DispatchQueue.main.async {
					guard currentSearchTimestamp == self.currentSearchTimestamp
						  && self.searchManager?.showSearchData == true else { return }
					self.searchManager?.reloadData()
					self.stopSpinner(inView: self.tableView)
				}
			}
		}
	}

	func closeSearch() {
		startSpinner(inView: view.superview)
		searchManager?.reloadData()
		stopSpinner(inView: view.superview)
	}
}

extension MapsController: DeepLinkable {

	public func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			if let map = object as? Map, type != "MapLocationable" {
				self?.deepLinkedMapLocationable = nil
				// second, make sure page is done loading:
				if self?.selectMap(map) == true {
					self?.deepLinkedMap = nil
				} else {
					self?.deepLinkedMap = map
				}
			} else if let mapLocation = object as? MapLocationable,
			   let mapId = mapLocation.inMapId,
			   let map = Map.get(id: mapId) {
				// second, make sure page is done loading:
				if self?.selectMap(map, mapLocation: mapLocation) == true {
					self?.deepLinkedMap = nil
					self?.deepLinkedMapLocationable = nil
				} else {
					self?.deepLinkedMap = map
					self?.deepLinkedMapLocationable = mapLocation
				}
			}
		}
	}
}
// swiftlint:enable file_length
