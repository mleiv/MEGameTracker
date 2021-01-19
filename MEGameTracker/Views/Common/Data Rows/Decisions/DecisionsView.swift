//
//  DecisionsView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class DecisionsView: SimpleArrayDataRow {

	@IBInspectable public var showHeading: Bool = true {
		didSet {
			nib?.headingLabelWrapper?.isHidden = !showHeading
		}
	}
	public var isShowGameVersion: Bool = true

	private lazy var dummyDecisions: [Decision] = {
		if let decision = Decision.getDummy() {
			return [decision]
		}
		return []
	}()
	public var decisions: [Decision] {
		return UIWindow.isInterfaceBuilder ? dummyDecisions : (controller?.decisions ?? [])
	}
	public var controller: Decisionsable? {
		didSet {
			reloadData()
		}
	}

	override var heading: String? { return showHeading ? "Decisions" : nil }
	override var cellNibs: [String] { return ["DecisionRow"] }
	override var rowCount: Int { return decisions.count }
	override var originHint: String? { return controller?.originHint }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard decisions.indices.contains((indexPath as NSIndexPath).row) else { return }
		(cell as? DecisionRow)?.define(
			decision: decisions[(indexPath as NSIndexPath).row],
			isShowGameVersion: isShowGameVersion
		)
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard decisions.indices.contains((indexPath as NSIndexPath).row) else { return }
		let decision = decisions[(indexPath as NSIndexPath).row]
		// load detail
		let bundle = Bundle(for: type(of: self))
		if let decisionNavigationController = UIStoryboard(name: "DecisionDetail", bundle: bundle)
			.instantiateInitialViewController() as? UINavigationController,
			let decisionDetail = decisionNavigationController.visibleViewController as? DecisionDetailController {
			// configure detail
			decisionDetail.decision = decision
			decisionDetail.originHint = originHint
			decisionDetail.decisionsView = self
			// present detail
			decisionNavigationController.modalPresentationStyle = .popover
			if let popover = decisionNavigationController.popoverPresentationController, let sender = sender {
				decisionDetail.preferredContentSize = CGSize(width: 400, height: 200)
				decisionDetail.popover = popover
				popover.sourceView = sender
				popover.sourceRect = sender.bounds
            }
			viewController?.present(decisionNavigationController, animated: true, completion: nil)
		}
	}

	override func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Decision.onChange.cancelSubscription(for: self)
		_ = Decision.onChange.subscribe(with: self) { [weak self] changed in
			if self?.decisions.contains(where: { $0.id == changed.id }) ?? false,
				   let newDecision = changed.object ?? Decision.get(id: changed.id) {
                DispatchQueue.main.async {
                    if let index = self?.decisions.firstIndex(where: { $0.id == newDecision.id }) {
                        self?.controller?.decisions[index] = newDecision
                        let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
                        self?.reloadRows(reloadRows)
                    }
                    // make sure controller listens here and updates its own object's decisions list
                }
			}
		}
	}

	override func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Decision.onChange.cancelSubscription(for: self)
	}

	var didInitializeInterfaceBuilder = false

	public override func layoutSubviews() {
		super.layoutSubviews()
		if UIWindow.isInterfaceBuilder && didSetup && !decisions.isEmpty && !didInitializeInterfaceBuilder {
			reloadData()
			tableView.isScrollEnabled = false
			didInitializeInterfaceBuilder = true
		}
	}
}
