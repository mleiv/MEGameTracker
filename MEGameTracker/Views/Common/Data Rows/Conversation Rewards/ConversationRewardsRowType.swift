//
//  ConversationRewardsRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct ConversationRewardsRowType: ValueDataRowType {
	public typealias RowType = ValueDataRow
	var view: RowType? { return row as? RowType }
	public var row: ValueDataRowDisplayable?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: ConversationRewardsable?
	public var onClick: ((UIButton) -> Void) = { _ in }

	public var heading: String? { return "Conversation Rewards" }
	public var value: String? {
		return UIWindow.isInterfaceBuilder
			? "5 Paragon, 6 Renegade"
			: controller?.mission?.conversationRewardsDescription
	}
	public var originHint: String? { return controller?.originHint }
	public var viewController: UIViewController? { return controller as? UIViewController }

	public init() {}
	public init(controller: ConversationRewardsable, view: ValueDataRow?) {
		self.controller = controller
		self.row = view
		let selfCopy = self
		self.onClick = { sender in
			selfCopy.openRow(sender: sender)
		}
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}

	public func openRow(sender: UIView?) {
		guard let view = view else { return }
		view.startParentSpinner(controller: viewController)
        let bundle = Bundle(for: type(of: view))
        if let navigationController = UIStoryboard(name: "ConversationRewardsDetail", bundle: bundle)
                .instantiateInitialViewController() as? UINavigationController,
            let rewardsController = navigationController.visibleViewController as? ConversationRewardsDetailController {
            rewardsController.mission = self.controller?.mission
            rewardsController.originHint = self.controller?.originHint
            rewardsController.originPrefix = "During"
            navigationController.modalPresentationStyle = .popover
            if let popover = navigationController.popoverPresentationController {
                rewardsController.preferredContentSize = CGSize(width: 400, height: 400)
                rewardsController.popover = popover
                popover.sourceView = sender
                popover.sourceRect = sender?.bounds ?? CGRect.zero
            }
            viewController?.present(navigationController, animated: true, completion: nil)
        }
        view.stopParentSpinner(controller: self.viewController)
	}
}
