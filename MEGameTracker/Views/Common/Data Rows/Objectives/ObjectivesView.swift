//
//  ObjectivesView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ObjectivesView: SimpleArrayDataRow {

	lazy var dummyRows: [MapLocationable] = {
		if let mission = Mission.getDummy() {
			return [mission]
		}
		return []
	}()
	public var objectives: [MapLocationable] {
		if UIWindow.isInterfaceBuilder {
			return dummyRows
		}
		return controller?.objectives ?? []
	}
	public var controller: Objectivesable? {
		didSet {
			reloadData()
		}
	}

	override var cellNibs: [String] { return ["MissionRow", "ItemRow"] }
	override var rowCount: Int { return objectives.count }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard objectives.indices.contains((indexPath as NSIndexPath).row) else { return }
		if let mission = objectives[(indexPath as NSIndexPath).row] as? Mission {
			_ = (cell as? MissionRow)?.define(mission: mission, origin: viewController)
		} else if let item = objectives[(indexPath as NSIndexPath).row] as? Item {
			_ = (cell as? ItemRow)?.define(item: item, origin: viewController)
		}
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		guard objectives.indices.contains((indexPath as NSIndexPath).row) else { return "Default" }
		if let _ = objectives[(indexPath as NSIndexPath).row] as? Mission {
			return cellNibs[0]
		} else if let _ = objectives[(indexPath as NSIndexPath).row] as? Item {
			return cellNibs[1]
		}
		return "Default"
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard objectives.indices.contains((indexPath as NSIndexPath).row) else { return }
		var objective = objectives[(indexPath as NSIndexPath).row]
		let mapId: String? = {
			if objective.isShowInParentMap,
                let mapId = objective.inMapId,
                let map = Map.get(id: mapId) {
				return map.inMapId
			} else {
				return objective.inMapId
			}
		}()
		startParentSpinner()
        if let mission = objective as? Mission, mission.isOpensDetail == true,
            openMission(mission) == true {
            // nothing else
        } else {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                var map: Map?
                if objective.mapLocationPoint == nil, let objectiveMapId = objective.inMapId {
                    let map = Map.get(id: objectiveMapId)
                    objective.mapLocationPoint = map?.mapLocationPoint
                }
                if mapId != map?.id, let mapId = mapId {
                    map = Map.get(id: mapId)
                }
                DispatchQueue.main.sync {
                    if objective is Item, let map = map,
                        self?.openObjective(objective, inMap: map) == true {
                        // nothing else
                    } else if let mission = objective as? Mission, mission.isOpensDetail == false, let map = map,
                        self?.openObjective(objective, inMap: map) == true {
                        // nothing else
                    } else {
                        self?.stopParentSpinner()
                    }
                }
            }
        }
	}

	private func openMission(_ mission: Mission) -> Bool {
        if let flowController = UIStoryboard(name: "MissionsFlow", bundle: Bundle(for: type(of: self)))
                .instantiateViewController(withIdentifier: "Mission") as? MissionsFlowController,
            let missionController = flowController.includedController as? MissionController {
            // configure detail
            missionController.mission = mission
//                    missionController.referringOriginHint = self.controller?.originHint
                self.viewController?.navigationController?.pushViewController(flowController, animated: true)
                self.stopParentSpinner()
            return true
        }
        return false
	}

	private func openObjective(_ objective: MapLocationable, inMap map: Map) -> Bool {
        if let flowController = UIStoryboard(name: "MapsFlow", bundle: Bundle(for: type(of: self)))
                .instantiateViewController(withIdentifier: "Map") as? MapsFlowController,
            let mapController = flowController.includedController as? MapSplitViewController {
            // configure detail
            mapController.map = map
            mapController.mapLocation = objective
            mapController.referringOriginHint = self.controller?.originHint
            self.viewController?.navigationController?.pushViewController(flowController, animated: true)
            self.stopParentSpinner()
            return true
        }
        return false
	}

	override func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(with: self) { [weak self] changed in
			if let index = self?.objectives.firstIndex(where: { $0.id == changed.id }),
				   let newRow = changed.object ?? Mission.get(id: changed.id) {
                DispatchQueue.main.async {
                    self?.controller?.objectives[index] = newRow
                    let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
                    self?.reloadRows(reloadRows)
                    // make sure controller listens here and updates its own object's decisions list
                }
			}
		}
		Item.onChange.cancelSubscription(for: self)
		_ = Item.onChange.subscribe(with: self) { [weak self] changed in
			if let index = self?.objectives.firstIndex(where: { $0.id == changed.id }),
				   let newRow = changed.object ?? Item.get(id: changed.id) {
                DispatchQueue.main.async {
                    self?.controller?.objectives[index] = newRow
                    let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
                    self?.reloadRows(reloadRows)
                    // make sure controller listens here and updates its own object's missions list
                }
			}
		}
	}

	override func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
		Item.onChange.cancelSubscription(for: self)
	}
}
