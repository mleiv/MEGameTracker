//
//  ShepardFlowController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/9/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

class ShepardFlowController: IBIncludedThing {
    
    static var appInit = false
    
    var appearanceController: ShepardAppearanceController? {
        for child in childViewControllers where !UIWindow.isInterfaceBuilder {
            if let appearanceController = child as? ShepardAppearanceController{
                return appearanceController
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ShepardFlowController.appInit {
            openApp()
        }
    }
    
    func openApp() {
        ShepardFlowController.appInit = false
    }
    
    @IBAction func closeModal(_ sender: AnyObject!) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveCode(_ sender: AnyObject!) {
        appearanceController?.save()
        if let splitViewController = includedController as? ShepardSplitViewController
            , splitViewController.detailPlaceholder?.isHidden == false {
            splitViewController.closeDetailStoryboard(sender)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func createGame(_ sender: AnyObject!) {
        App.current.addNewGame()
        closeModal(sender)
    }
    
}

