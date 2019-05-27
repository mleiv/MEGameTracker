//
//  MissionGroupsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
// TODO: Refactor

final class MissionsGroupsController: UITableViewController, Spinnerable {

    let changeQueue = DispatchQueue(label: "MissionsGroupsController.data", qos: .background)
    let transitionQueue = DispatchQueue(label: "MissionsGroupsController.transition", qos: .background)

	var shepardUuid: UUID?
	var didSetup = false
	var isUpdating = false

	enum MissionsGroupsSection: Int {
		case main = 0, recent
	}

	var precachedMissions: [MissionType: [Mission]] = [:]
	var recentMissions: [Mission] = []
	var searchedMissions: [MissionType: [Mission]] = [:]

	typealias MissionsGroupCounts = MissionStatusCounts
	var missionCounts: [MissionType: MissionsGroupCounts] = [:]

	@IBOutlet weak var tempSearchBar: UISearchBar!
	var searchManager: MESearchManager?
	var currentSearchTimestamp: Date?

	var deepLinkedMission: Mission?
	var lastSelectedMissionsGroup: MissionType?

	public var onPreCacheFinished = Signal<(type: MissionType, values: [Mission])>()

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	func setup(isReloadData: Bool = false) {
		startSpinner(inView: tableView)
		isUpdating = true
		defer {
			stopSpinner(inView: tableView)
			didSetup = true
			isUpdating = false
		}

		setupTableCustomCells()
		setupSearch()
		setupMissionGroups(isReloadData: isReloadData)
		setupRecentlyViewed(isReloadData: isReloadData)

		guard !UIWindow.isInterfaceBuilder else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
			self?.deepLink(self?.deepLinkedMission)
		}
	}

	func setupMissionCounts() {
		fetchMissionCountData()
	}

	func setupMissionGroups(isReloadData: Bool = false) {
		setupMissionCounts()
		if isReloadData {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
		precacheMissions()
	}

	func setupRecentlyViewed(isReloadData: Bool = false) {
		fetchRecentMissionData()
		if isReloadData && !UIWindow.isInterfaceBuilder {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	func fetchMissionCountData() {
		precachedMissions = [:]
		missionCounts = [:]
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		let gameVersion = App.current.gameVersion
		for type in MissionType.categories() {
			let counts = Mission.getCountedMissionStatus(missionType: type, gameVersion: gameVersion)
			guard gameVersion == App.current.gameVersion else { return }
			if counts.total > 0 {
				missionCounts[type] = counts
			}
		}
		shepardUuid = App.current.game?.shepard?.uuid
	}

	func fetchRecentMissionData() {
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		let gameVersion = App.current.gameVersion
		recentMissions = Mission.getAllRecent(gameVersion: gameVersion)
		shepardUuid = App.current.game?.shepard?.uuid
	}

	func fetchDummyData() {
		missionCounts[.mission] = (total: 27, available: 15, unavailable: 10, completed: 2)
		missionCounts[.assignment] = (total: 57, available: 32, unavailable: 25, completed: 0)
		missionCounts[.dlc] = (total: 11, available: 8, unavailable: 2, completed: 1)
		recentMissions = [Mission.getDummy()].compactMap { $0 }
	}

	func precacheMissions() {
        let gameVersion = App.current.gameVersion
        for type in missionCounts.keys {
            let missions = Mission.getAllType(type, gameVersion: gameVersion).sorted(by: Mission.sort)
            onPreCacheFinished.fire((type: type, values: missions))
            // cancel if we switched missions mid-query:
            guard gameVersion == App.current.gameVersion else { return }
            changeQueue.sync { [weak self] in
                self?.precachedMissions[type] = missions
                if missionCounts[type]?.unavailable == 0 {
                    self?.recountMissions(type: type)
                    // update rows
                    if let index = self?.missionsRowByType(type) {
                        self?.reloadRows([IndexPath(row: index, section: MissionsGroupsSection.main.rawValue)])
                    }
                }
            }
        }
	}

	func recountMissions(type: MissionType) {
        let missions = precachedMissions[type] ?? []
        let totalCount = missionCounts[type]?.total ?? 0
        let completedCount = missions.reduce(0, {
            // note: completed missions can also be unavailable, so exclude them for count
            $0 + ($1.isCompleted ? 1: 0)
        })
        let unavailableCount = missions.reduce(0, {
            // note: completed missions can also be unavailable, so exclude them for count
            $0 + (!$1.isAvailable && !$1.isCompleted ? 1: 0)
        })
        missionCounts[type]?.completed = completedCount
        missionCounts[type]?.unavailable = unavailableCount
        missionCounts[type]?.available = totalCount - (unavailableCount + completedCount)
	}

	func missionsTypeByRow(_ row: Int) -> MissionType? {
		let sections = Array(missionCounts.keys)
		let sortedSections = sections.sorted { $0.intValue < $1.intValue }
		return sortedSections.indices.contains(row) ? sortedSections[row] : nil
	}

	func missionsRowByType(_ type: MissionType) -> Int? {
		let sections = Array(missionCounts.keys)
		let sortedSections = sections.sorted { $0.intValue < $1.intValue }
		return sortedSections.firstIndex(of: type)
	}

	func searchedMissionsTypeBySection(_ section: Int) -> MissionType? {
		let sections = Array(searchedMissions.keys)
		let sortedSections = sections.sorted { $0.intValue < $1.intValue }
		return sortedSections.indices.contains(section) ? sortedSections[section] : nil
	}

}

// MARK: Segues
extension MissionsGroupsController {

	/// Invoked from deep links
	func selectMission(_ mission: Mission?) -> Bool {
		guard let mission = mission else { return false }
		DispatchQueue.main.async { [weak self] in
			self?.segueToMission(mission, sender: nil)
		}
		return true
	}

	/// Invoked from recently viewed and selectMission above
	func segueToMission(_ mission: Mission?, sender: AnyObject? = nil) {
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		transitionQueue.sync {
			// Uses strong self (don't want to give up page until spinner is turned off)
			self.deepLinkedMission = mission
			self.lastSelectedMissionsGroup = mission?.missionType
			DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
				self.parent?.performSegue(withIdentifier: "Show MissionsFlow.MissionsGroup", sender: sender)
				self.stopSpinner(inView: self.view.superview)
			}
		}
	}

	/// Invoked from mission category row
	func segueToMissionsGroup(_ missionType: MissionType, sender: AnyObject?) {
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		transitionQueue.sync {
			// Uses strong self (don't want to give up page until spinner is turned off)
			self.lastSelectedMissionsGroup = missionType
			DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
				self.parent?.performSegue(withIdentifier: "Show MissionsFlow.MissionsGroup", sender: sender)
				self.stopSpinner(inView: self.view.superview)
			}
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let type = lastSelectedMissionsGroup ?? .mission
		let totalCount = missionCounts[type]?.total ?? 0
		let missions = precachedMissions[type]
		if type == .objective {
			// TODO: deep link to parent mission instead
		}
		segue.destination.find(controllerType: MissionsSplitViewController.self) { controller in
			controller.missionsType = type
			controller.missionsCount = totalCount
			controller.missions = missions ?? []
			controller.isLoadedSignal = self.onPreCacheFinished
			if let mission = self.deepLinkedMission {
				controller.deepLink(mission)
			}
			self.clearMissionSegue()
		}
	}

	func clearMissionSegue() {
		deepLinkedMission = nil
		lastSelectedMissionsGroup = nil
	}
}

// MARK: Local UITableView Customization
extension MissionsGroupsController {

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(
			UINib(nibName: "MissionsGroupRow", bundle: bundle),
			forCellReuseIdentifier: "MissionsGroupRow"
		)
		tableView.register(
			UINib(nibName: "MissionRow", bundle: bundle),
			forCellReuseIdentifier: "MissionRow"
		)
	}

	func setupSearchMissionRow(_ indexPath: IndexPath, cell: MissionRow) -> MissionRow {
		if let type = searchedMissionsTypeBySection((indexPath as NSIndexPath).section),
			searchedMissions[type]?.indices.contains((indexPath as NSIndexPath).row) == true {
			_ = cell.define(mission: searchedMissions[type]?[(indexPath as NSIndexPath).row], origin: self)
		}
		return cell
	}

	func setupMissionRow(_ indexPath: IndexPath, cell: MissionRow) -> MissionRow {
		if recentMissions.indices.contains((indexPath as NSIndexPath).row) {
			_ = cell.define(mission: recentMissions[(indexPath as NSIndexPath).row], origin: self)
		}
		return cell
	}

	func setupMissionGroupRow(_ indexPath: IndexPath, cell: MissionsGroupRow) -> MissionsGroupRow {
		if let type = missionsTypeByRow((indexPath as NSIndexPath).row) {
			cell.define(
				name: type.headingValue,
				availableCount: missionCounts[type]?.available ?? 0,
				unavailableCount: missionCounts[type]?.unavailable ?? 0,
				completedCount: missionCounts[type]?.completed ?? 0
			)
		}
		return cell
	}
}

// MARK: Table View reload rows - TODO: move to protocol
extension MissionsGroupsController {

	func reloadAllRows() {
		reloadMainRows()
		reloadRecentRows()
	}

	func reloadMainRows() {
		guard !isUpdating else { return }
		isUpdating = true
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		changeQueue.sync {
			self.setupMissionGroups(isReloadData: true)
			DispatchQueue.main.async {
				self.stopSpinner(inView: self.view.superview)
				self.isUpdating = false
			}
		}
	}

	func reloadRecentRows(_ x: Bool = false) {
		guard !isUpdating else { return }
		isUpdating = true
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view.superview)
		}
		changeQueue.sync {
			self.setupRecentlyViewed(isReloadData: true)
			DispatchQueue.main.async {
				self.stopSpinner(inView: self.view.superview)
				self.isUpdating = false
			}
		}
	}

	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			reloadAllRows()
		}
	}
}

extension MissionsGroupsController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}

// MARK: Protocol - UITableViewDelegate
extension MissionsGroupsController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		if tableView != self.tableView { // search
			return searchedMissions.count
		} else {
			return 2
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if tableView != self.tableView { // search
			if searchedMissions.isEmpty {
				return 0
			}
			if section == 0 {
				return 30 // needs extra padding for some reason
			}
		} else {
			if section == MissionsGroupsSection.main.rawValue {
				return 0
			}
		}
		return 15
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView != self.tableView { // search
			if let type = searchedMissionsTypeBySection(section) {
				return type.headingValue
			}
			return nil
		} else {
			if section == MissionsGroupsSection.recent.rawValue {
				return "Recently Viewed"
			}
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView != self.tableView { // search
			if let type = searchedMissionsTypeBySection(section) {
				return searchedMissions[type]?.count ?? 0
			}
			return 0
		} else {
			switch section {
			case MissionsGroupsSection.main.rawValue: return missionCounts.count
			case MissionsGroupsSection.recent.rawValue: return recentMissions.count
			default: return 0
			}
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView != self.tableView { // search
			if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionRow") as? MissionRow {
				return setupSearchMissionRow(indexPath, cell: cell)
			}
			return super.tableView(tableView, cellForRowAt: indexPath)
		} else {
			switch (indexPath as NSIndexPath).section {
			case MissionsGroupsSection.main.rawValue:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionsGroupRow") as? MissionsGroupRow {
					return setupMissionGroupRow(indexPath, cell: cell)
				}
			case MissionsGroupsSection.recent.rawValue:
				if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionRow") as? MissionRow {
					return setupMissionRow(indexPath, cell: cell)
				}
			default: break
			}
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell: UITableViewCell?
		DispatchQueue.main.async {
            cell = tableView.cellForRow(at: indexPath)
			self.startSpinner(inView: self.view.superview)
            DispatchQueue.global(qos: .background).async {
                // strong self (don't want to give up page until spinner is turned off)
                if tableView != self.tableView { // search
                    if let missionRow = cell as? MissionRow {
                        var mission = missionRow.mission
                        // can't link to objectives directly
                        while let inMissionId = mission?.inMissionId,
                            let mission2 = Mission.get(id: inMissionId) {
                            mission = mission2
                        }
                        self.segueToMission(mission, sender: cell)
                        return
                    }
                } else {
                    if let missionRow = cell as? MissionRow {
                        self.segueToMission(missionRow.mission, sender: cell)
                        return
                    } else if let type = self.missionsTypeByRow((indexPath as NSIndexPath).row) {
                        self.segueToMissionsGroup(type, sender: cell)
                        return
                    }
                }
                DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
                    self.stopSpinner(inView: self.view.superview)
                }
            }
        }
    }
}

// MARK: Listeners
extension MissionsGroupsController {

	private func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(with: self, callback: reloadOnShepardChange)
		// listen for changes to recently viewed list
		App.onRecentlyViewedMissionsChange.cancelSubscription(for: self)
		_ = App.onRecentlyViewedMissionsChange.subscribe(with: self, callback: reloadRecentRows)
		// listen for changes to mission data
		Mission.onChange.cancelSubscription(for: self)
        _ = Mission.onChange.subscribe(with: self, callback: processChangedMission)
		// decisions are loaded at detail page, don't have to listen
	}

	/// Changes any local data and UI to reflect an updated mission.
    /// Triggered from background queue
	private func processChangedMission(_ changed: (id: String, object: Mission?)) {
		// check counts and cache
		// we do a pre-check that this mission id is in our list, and then a proper index later once we know mission type.
        if precachedMissions.contains(where: { $0.1.contains(where: { $0.id == changed.id }) }),
			let newMission = changed.object ?? Mission.get(id: changed.id),
			let index = precachedMissions[newMission.missionType]?.firstIndex(where: { $0.id == newMission.id }) {
            changeQueue.sync { [weak self] in
                // change counts
                self?.processChangedMissionCounts(newMission)
            }
            // update cached data
            var missions = precachedMissions[newMission.missionType] ?? []
            missions[index] = newMission
            missions = missions.sorted(by: Mission.sort)
            changeQueue.sync { [weak self] in
                self?.precachedMissions[newMission.missionType] = missions
            }
        }

		// check recently viewed
		if let index = recentMissions.firstIndex(where: { $0.id == changed.id }),
			let newMission = changed.object ?? Mission.get(id: changed.id) {
            changeQueue.sync { [weak self] in
                self?.recentMissions[index] = newMission
                self?.reloadRows([IndexPath(row: index, section: MissionsGroupsSection.recent.rawValue)])
            }
		}
	}

	/// Changes any local data and UI to reflect updated missions groups counts.
    /// Triggered from changeQueue
	private func processChangedMissionCounts(_ newMission: Mission) {
		guard let index = precachedMissions[newMission.missionType]?.firstIndex(where: { $0.id == newMission.id }),
            let oldMission = precachedMissions[newMission.missionType]?[index]
		else {
			return
		}

		// check for changes
		let isCompletedCountChange = oldMission.isCompleted != newMission.isCompleted
		let isAvailableCountChange = oldMission.isAvailable != newMission.isAvailable
        precachedMissions[newMission.missionType]?[index] = newMission
        if isCompletedCountChange || isAvailableCountChange {
            recountMissions(type: newMission.missionType)
            // update rows
            if let rowIndex = missionsRowByType(newMission.missionType) {
                reloadRows([IndexPath(row: rowIndex, section: MissionsGroupsSection.main.rawValue)])
            }
        }
	}
}

// MARK: MESearchManager
extension MissionsGroupsController {

	func setupSearch() {
		guard !UIWindow.isInterfaceBuilder else { return }

		// create a separate results view:
		let resultsController = UITableViewController(style: .grouped)
		let bundle =  Bundle(for: type(of: self))
		resultsController.tableView?.register(
			UINib(nibName: "MissionRow", bundle: bundle),
			forCellReuseIdentifier: "MissionRow"
		)
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
			searchData: searchMissions,
			closeSearch: closeSearch
		)
		tableView.tableHeaderView = searchManager?.searchController?.searchBar
		// (doesn't size right if we try to use a container view controlled by search manager)
	}

	func searchMissions(_ search: String? = nil) {
		guard search?.isEmpty == false else {
			stopSpinner(inView: tableView)
			return
		}
		startSpinner(inView: tableView)
		searchedMissions = [:]
		if !UIWindow.isInterfaceBuilder, let search = search {
			let currentSearchTimestamp = Date()
			self.currentSearchTimestamp = currentSearchTimestamp
			searchManager?.reloadData()
			changeQueue.sync {
				// Uses strong self (don't want to give up page until spinner is turned off)
//				print("\n\nSearching: \(search)")
				let missions = Mission.getAll(likeName: search).sorted(by: Mission.sort)
				guard currentSearchTimestamp == self.currentSearchTimestamp
					  && self.searchManager?.showSearchData == true else { return }
	//			missions = missions.sort(Mission.sort)
				for mission in missions {
					guard currentSearchTimestamp == self.currentSearchTimestamp
						  && self.searchManager?.showSearchData == true else { return }
					if self.searchedMissions.keys.contains(mission.missionType) != true {
						self.searchedMissions[mission.missionType] = []
					}
					self.searchedMissions[mission.missionType]?.append(mission)
				}
				DispatchQueue.main.async { // strong self (don't want to give up page until spinner is turned off)
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

extension MissionsGroupsController: DeepLinkable {

	// MARK: DeepLinkable protocol

	func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		guard !UIWindow.isInterfaceBuilder else { return }
		guard let object = object else { return }
		DispatchQueue.main.async { [weak self] in
			self?.startSpinner(inView: self?.view.superview)
		}
		transitionQueue.sync { [weak self] in
			if let mission = object as? Mission {
				if self?.selectMission(mission) == true {
//					self?.deepLinkedMission = nil
				} else {
					self?.deepLinkedMission = mission // wait
				}
			}
		}
	}
}
// swiftlint:disable file_length
