//
//  MissionsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class MissionsController: UITableViewController, Spinnerable {

	var missionsSplitViewController: MissionsSplitViewController? {
		guard !UIWindow.isInterfaceBuilder else { return nil }
		return parent as? MissionsSplitViewController
	}

	// set by page controller parent
	var missionsType: MissionType {
		return missionsSplitViewController?.missionsType ?? .mission
	}
	var missionsCount: Int {
		return missionsSplitViewController?.missionsCount ?? 0
	}
	var missions: [Mission] {
		get {
			guard !UIWindow.isInterfaceBuilder else {
				return [Mission.getDummy(), Mission.getDummy()].flatMap { $0 }
			}
			return missionsSplitViewController?.missions ?? []
		}
		set {
			missionsSplitViewController?.missions = newValue
		}
	}
	var deepLinkedMission: Mission? {
		get {
			return missionsSplitViewController?.deepLinkedMission
		}
		set {
			missionsSplitViewController?.deepLinkedMission = newValue
		}
	}
	var isLoadedSignal: Signal<(type: MissionType, values: [Mission])>? {
		return missionsSplitViewController?.isLoadedSignal
	}

	var shepardUuid: UUID?
	var isUpdating = false
	var didSetup = false

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		deepLink(deepLinkedMission)
	}

	// MARK: Setup Page Elements

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "MissionRow", bundle: bundle), forCellReuseIdentifier: "MissionRow")
	}

	func setup(isForceReloadData: Bool = false) {
		startSpinner(inView: view.superview)
		isUpdating = true
		defer {
			stopSpinner(inView: view.superview)
			didSetup = true
			isUpdating = false
		}
		setupTableCustomCells()
		fetchData()
		parent?.parent?.navigationItem.title = missionsType.headingValue
		if isForceReloadData {
			tableView.reloadData()
		}
	}

	func fetchData() {
		guard !UIWindow.isInterfaceBuilder else { return }
		shepardUuid = App.current.game?.shepard?.uuid
		missions = Mission.getAllType(missionsType, gameVersion: App.current.gameVersion).sorted(by: Mission.sort)
	}

	func setupRow(_ row: Int, cell: MissionRow) {
		if row < missions.count {
			_ = cell.define(mission: missions[row], origin: self)
		} else {
			_ = cell.define(mission: nil, origin: self)
		}
	}

	// MARK: Actions

	func selectMission(_ mission: Mission?) -> Bool {
		guard let mission = mission else { return false }
		if let index = missions.index(of: mission) {
			DispatchQueue.main.async { [weak self] in
				let indexPath = IndexPath(row: index, section: 0)
				let cell = self?.tableView.cellForRow(at: indexPath)
				self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
				self?.segueToMission(mission, sender: cell)
			}
			return true
		} else if missions.isEmpty {
			return false // wait
		} else {
			DispatchQueue.main.async { [weak self] in
				self?.segueToMission(mission, sender: nil)
			}
			return true
		}
	}

	func segueToMission(_ mission: Mission?, sender: AnyObject? = nil) {
		DispatchQueue.main.async {
			if self.deepLinkedMission != nil {
				self.startSpinner(inView: self.view.superview)
			}
		}
		DispatchQueue.global(qos: .background).async {
			if let parentController = self.parent as? MissionsSplitViewController {
				let ferriedSegue: FerriedPrepareForSegueClosure = {
					(destinationController: UIViewController) in
					destinationController.find(controllerType: MissionController.self) { controller in
						controller.mission = mission
					}
				}
				DispatchQueue.main.async {
					parentController.performChangeableSegue("Show MissionsFlow.Mission",
						sender: nil,
						ferriedSegue: ferriedSegue
					)
					self.stopSpinner(inView: self.view.superview)
				}
				return
			}
			DispatchQueue.main.async {
				self.stopSpinner(inView: self.view.superview)
			}
		}
	}

	// MARK: Protocol - UITableViewDelegate

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		return missions.isEmpty ? missionsCount : missions.count
	}

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MissionRow") as? MissionRow {
			setupRow((indexPath as NSIndexPath).row, cell: cell)
			return cell
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}

	override func tableView(
		_ tableView: UITableView,
		estimatedHeightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	override func tableView(
		_ tableView: UITableView,
		heightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	override func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		if (indexPath as NSIndexPath).row < missions.count {
			segueToMission(self.missions[(indexPath as NSIndexPath).row])
		}
	}

}

extension MissionsController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}

// MARK: Table View reload rows - TODO: move to protocol
extension MissionsController {

	func reloadAllRows() {
		guard !isUpdating else { return }
		DispatchQueue.main.async {
			self.setup(isForceReloadData: true)
		}
	}

	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			reloadAllRows()
		}
	}

}

// MARK: Listeners
extension MissionsController {

	private func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		registerPreCacheListener()
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
		// listen for changes to mission data
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(on: self) { [weak self] changed in
			if let index = self?.missions.index(where: { $0.id == changed.id }),
				let newMission = changed.object ?? Mission.get(id: changed.id),
				newMission.missionType != .objective {
				self?.missions[index] = newMission
				let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
				self?.reloadRows(reloadRows)
			}
		}
		// decisions are loaded at detail page, don't have to listen
	}

	public func registerPreCacheListener() {
		guard missions.isEmpty else { return }
		let signal = isLoadedSignal
		signal?.cancelSubscription(for: self)
		signal?.subscribeOnce(on: self) { [weak self] (type: MissionType, values: [Mission]) in
			guard type == self?.missionsType else { return }
			self?.missions = values
			self?.reloadAllRows()
		}
	}
}

extension MissionsController: DeepLinkable {

	func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		guard !UIWindow.isInterfaceBuilder else { return }
		guard let object = object else { return }
		DispatchQueue.main.async { [weak self] in
			self?.startSpinner(inView: self?.view.superview)
		}
		DispatchQueue.global(qos: .background).async { [weak self] in
			if let mission = object as? Mission {
				if self?.selectMission(mission) == true {
					self?.deepLinkedMission = nil
				} else {
					self?.deepLinkedMission = mission // wait
				}
			}
		}
	}
}
