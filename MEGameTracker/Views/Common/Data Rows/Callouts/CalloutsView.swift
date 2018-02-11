//
//  CalloutsView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/9/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class CalloutsView: SimpleArrayDataRow {

	lazy var dummyRows: [MapLocationable] = {
		if let mission = Mission.getDummy() {
			return [mission]
		}
		return []
	}()
    var lastCalloutCount = 0
	public var callouts: [MapLocationable] {
		if UIWindow.isInterfaceBuilder {
			return dummyRows
		}
//        if ((controller?.callouts.count ?? 0) != lastCalloutCount) {
//            lastCalloutCount = controller?.callouts.count ?? 0
//        }
		return controller?.callouts ?? []
	}
	public var shouldSegueToCallout: Bool = true
	public var controller: Calloutsable? {
		didSet {
			reloadData()
		}
	}

	public var estimatedHeight: CGFloat {
		return nib?.tableView?.contentSize.height ?? 0
	}
	public var estimatedWidth: CGFloat {
		var maxWidth: CGFloat = 0.0
		for row in 0..<(nib?.tableView?.numberOfRows(inSection: 0) ?? 0) {
			let indexPath = IndexPath(row: row, section: 0)
			if let cell = nib?.tableView?.cellForRow(at: indexPath) as? CalloutCellType {
				maxWidth = max(maxWidth, cell.estimatedWidth)
			}
		}
		return maxWidth
	}

	var lastSelectedCallout: MapLocationable?
	var isVisible = false

	public func select(mapLocation: MapLocationable?, sender: UIView?) {
		guard let mapLocation = mapLocation else { return }
		if let index = callouts.index(where: { $0.isEqual(mapLocation) }) {
			let indexPath = IndexPath(row: index, section: 0)
			openRow(indexPath: indexPath, sender: sender)
		}
	}

	override public func didMoveToSuperview() {
		if superview == nil {
			removeListeners()
			isVisible = false
		} else {
			if didSetup {
				startListeners()
			}
			isVisible = true
		}
	}

	// TODO: extract cell rows to MapLocationType enum
	override var cellNibs: [String] { return ["MapRow", "MissionRow", "ItemRow", "NothingRow"] }
	override var rowCount: Int { return max(1, callouts.count) }
	override var viewController: UIViewController? { return controller?.viewController }

	override func setup() {
		isSettingUp = true
		if nib == nil, let view = CalloutsNib.loadNib(cellNibs: cellNibs) {
			insertSubview(view, at: 0)
			view.fillView(self)
			nib = view
		}
		super.setup()
	}

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard callouts.indices.contains((indexPath as NSIndexPath).row) else { return }
		let isCalloutBoxRow = controller is MapCalloutsBoxNib
		if let map = callouts[(indexPath as NSIndexPath).row] as? Map {
			_ = (cell as? MapRow)?.define(
				map: map,
				origin: viewController,
				isCalloutBoxRow: isCalloutBoxRow,
				allowsSegue: calloutAllowsSegue(callout: map),
				isShowParentMapIfFound: !isCalloutBoxRow
			)
		} else if let mission = callouts[(indexPath as NSIndexPath).row] as? Mission {
			_ = (cell as? MissionRow)?.define(
				mission: mission,
				origin: viewController,
				isCalloutBoxRow: isCalloutBoxRow,
				allowsSegue: calloutAllowsSegue(callout: mission),
				isShowParentMissionIfFound: true
			)
		} else if let item = callouts[(indexPath as NSIndexPath).row] as? Item {
			_ = (cell as? ItemRow)?.define(
				item: item,
				origin: viewController,
				isCalloutBoxRow: isCalloutBoxRow,
				allowsSegue: calloutAllowsSegue(callout: item),
				isShowParentMissionIfFound: true
			)
		}
		if controller is MapCalloutsBoxNib {
			cell.selectionStyle = .none
		}
	}

	func calloutAllowsSegue(callout: MapLocationable) -> Bool {
		let hasNoCallout = controller?.inMap?.id == callout.inMapId && callout.mapLocationPoint == nil
		return shouldSegueToCallout || hasNoCallout
	}

	func showSpinnerForRow(callout: MapLocationable) -> Bool {
		let isFromCalloutsPage = viewController is MapCalloutsGroupsController // always popup these
		return !calloutAllowsSegue(callout: callout) || isFromCalloutsPage || callout.isOpensDetail == true
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		guard callouts.indices.contains((indexPath as NSIndexPath).row) else { return cellNibs[3] }
		if let _ = callouts[indexPath.row] as? Map {
			return cellNibs[0]
		} else if let _ = callouts[indexPath.row] as? Mission {
			return cellNibs[1]
		} else if let _ = callouts[indexPath.row] as? Item {
			return cellNibs[2]
		}
		return cellNibs[3]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard callouts.indices.contains((indexPath as NSIndexPath).row) else { return }
		// TODO: don't show spinner on callout box trigger?
		let callout = callouts[(indexPath as NSIndexPath).row]
		if showSpinnerForRow(callout: callout) {
			startParentSpinner()
		}
		lastSelectedCallout = callout
		DispatchQueue.global(qos: .background).async {
			if !self.calloutAllowsSegue(callout: callout) {
				DispatchQueue.main.async {
					MapLocation.onChangeSelection.fire(callout)
					self.closeCalloutsWindowIfFound()
					self.stopParentSpinner()
				}
				return
			} else if let missionId = (callout as? Item)?.inMissionId,
				let linkedMission = Mission.get(id: missionId) {
				if self.openMission(linkedMission) {
					return
				}
			} else if let _ = callout as? Item {
				DispatchQueue.main.async {
					// TODO: an items detail page?
					MapLocation.onChangeSelection.fire(callout)
					self.closeCalloutsWindowIfFound()
					self.stopParentSpinner()
				}
				return
			} else if let mission = callout as? Mission, mission.missionType != .objective {
				if self.openMission(mission) {
					return
				}
			} else if let missionId = (callout as? Mission)?.inMissionId,
				let linkedMission = Mission.get(id: missionId) {
				if self.openMission(linkedMission) {
					return
				}
			} else if let mapId = (callout as? Map)?.linkToMapId,
				let linkedMap = Map.get(id: mapId) {
				if self.openMap(linkedMap) {
					return
				}
			} else if let map = callout as? Map, map.isOpensDetail == true { // skip stuff that has no other data
				if self.openMap(map) {
					return
				}
			}
			self.stopParentSpinner()
		}
	}

	private func openMission(_ mission: Mission) -> Bool {
		let bundle = Bundle(for: type(of: self))
		if let flowController = UIStoryboard(name: "MissionsFlow", bundle: bundle)
				.instantiateViewController(withIdentifier: "Mission") as? MissionsFlowController,
			let missionController = flowController.includedController as? MissionController {
			// configure detail
			missionController.mission = mission
			DispatchQueue.main.async {
				self.controller?.navigationPushController?.pushViewController(flowController, animated: true)
				self.closeCalloutsWindowIfFound(isForce: true)
				self.stopParentSpinner()
			}
			return true
		}
		return false
	}

	private func openMap(_ map: Map) -> Bool {
		let bundle = Bundle(for: type(of: self))
		if let flowController = UIStoryboard(name: "MapsFlow", bundle: bundle)
				.instantiateViewController(withIdentifier: "Map") as? MapsFlowController,
			let mapController = flowController.includedController as? MapSplitViewController {
			// configure detail
			mapController.map = map
			DispatchQueue.main.async {
				self.controller?.navigationPushController?.pushViewController(flowController, animated: true)
				self.closeCalloutsWindowIfFound(isForce: true)
				self.stopParentSpinner()
			}
			return true
		}
		return false
	}

	private func reloadOnCalloutChange<T: GameRowStorable & DateModifiable>(
        type: T.Type,
        changed: (id: String, object: T?)
    ) {
        var callouts = controller?.callouts ?? []
        if let index = callouts.index(where: { $0.id == changed.id }),
           let callout = changed.object ?? T.get(id: changed.id),
           callout.modifiedDate > (callouts[index] as? T)?.modifiedDate ?? Date.distantPast {
            if let newRow = callout as? MapLocationable {
                callouts[index] = newRow
                controller?.updateCallouts(callouts)
            }
            DispatchQueue.main.async { [weak self] in
                self?.reloadRows([IndexPath(row: index, section: 0)])
            }
        }
	}

	override func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
        Map.onChange.cancelSubscription(for: self)
        _ = Map.onChange.subscribe(on: self) { [weak self] changed in
            self?.reloadOnCalloutChange(type: Map.self, changed: changed)
        }
        Mission.onChange.cancelSubscription(for: self)
        _ = Mission.onChange.subscribe(on: self) { [weak self] changed in
            self?.reloadOnCalloutChange(type: Mission.self, changed: changed)
        }
        Item.onChange.cancelSubscription(for: self)
        _ = Item.onChange.subscribe(on: self) { [weak self] changed in
            self?.reloadOnCalloutChange(type: Item.self, changed: changed)
        }
		MapLocation.onChangeSelection.cancelSubscription(for: self)
		_ = MapLocation.onChangeSelection.subscribe(on: self) { [weak self] (mapLocation: MapLocationable) in
			guard mapLocation.shownInMapId == self?.callouts.first?.shownInMapId else { return }
			self?.highlight(mapLocation: mapLocation)
		}
	}

	override func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
//        Map.onChange.cancelSubscription(for: self)
//        Mission.onChange.cancelSubscription(for: self)
//        Item.onChange.cancelSubscription(for: self)
		MapLocation.onChangeSelection.cancelSubscription(for: self)
	}

	func highlight(mapLocation: MapLocationable?) {
		guard isVisible, let mapLocation = mapLocation else { return }
		if let index = callouts.index(where: { $0.isEqual(mapLocation) }) {
			nib?.tableView?.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
		}
	}

	func closeCalloutsWindowIfFound(isForce: Bool = false) {
		if isForce || nib?.tableView?.traitCollection.horizontalSizeClass == .compact {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
				(self.viewController as? MapCalloutsGroupsController)?.closeCallouts()
			}
		}
	}
}
