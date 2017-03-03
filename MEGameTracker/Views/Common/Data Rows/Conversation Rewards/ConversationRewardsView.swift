//
//  ConversationRewardsView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ConversationRewardsView: SimpleValueDataRow {
    
    public var controller: ConversationRewardsable? {
        didSet {
            reloadData()
        }
    }
    
    override var heading: String? { return "Conversation Rewards" }
    override var value: String? {
        return UIWindow.isInterfaceBuilder ? "5 Paragon, 6 Renegade" : controller?.mission?.conversationRewardsDescription
    }
    override var originHint: String? { return controller?.originHint }
    override var viewController: UIViewController? { return controller as? UIViewController }
    
    override func openRow(sender: UIView?) {
        startParentSpinner()
        DispatchQueue.global(qos: .background).async {
            if let navigationController = UIStoryboard(name: "ConversationRewardsDetail", bundle: Bundle(for: type(of: self))).instantiateInitialViewController() as? UINavigationController,
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
                DispatchQueue.main.async {
                    self.viewController?.present(navigationController, animated: true, completion: nil)
                    self.stopParentSpinner()
                }
                return
            }
            self.stopParentSpinner()
        }
    }
}


