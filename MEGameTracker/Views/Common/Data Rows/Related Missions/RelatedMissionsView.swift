//
//  RelatedMissionsView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class RelatedMissionsView: SimpleArrayDataRow {

	lazy var dummyMissions: [Mission] = {
		if let mission = Mission.getDummy() {
			return [mission]
		}
		return []
	}()
	public var missions: [Mission] {
		if UIWindow.isInterfaceBuilder {
			return dummyMissions
		}
		return controller?.relatedMissions ?? []
	}
	public var controller: RelatedMissionsable? {
		didSet {
			reloadData()
		}
	}

	override var heading: String? { return "Related Missions" }
	override var cellNibs: [String] { return ["MissionRow"] }
	override var rowCount: Int { return missions.count }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard missions.indices.contains((indexPath as NSIndexPath).row) else { return }
		_ = (cell as? MissionRow)?.define(mission: missions[(indexPath as NSIndexPath).row], origin: viewController)
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard missions.indices.contains((indexPath as NSIndexPath).row) else { return }
		let mission = missions[(indexPath as NSIndexPath).row]
		startParentSpinner()
		DispatchQueue.global(qos: .background).async {
			let bundle = Bundle(for: type(of: self))
			if let flowController = UIStoryboard(name: "MissionsFlow", bundle: bundle)
					.instantiateViewController(withIdentifier: "Mission") as? MissionsFlowController,
				let missionController = flowController.includedController as? MissionController {
				// configure detail
				missionController.mission = mission
				DispatchQueue.main.async {
					self.viewController?.navigationController?.pushViewController(flowController, animated: true)
					self.stopParentSpinner()
				}
				return
			}
			self.stopParentSpinner()
		}
	}

	override func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(on: self) { [weak self] changed in
			if let index = self?.missions.index(where: { $0.id == changed.id }),
				   let newRow = changed.object ?? Mission.get(id: changed.id) {
				self?.controller?.relatedMissions[index] = newRow
				let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
				self?.reloadRows(reloadRows)
				// make sure controller listens here and updates its own object's decisions list
			}
		}
	}

	override func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
	}
}
