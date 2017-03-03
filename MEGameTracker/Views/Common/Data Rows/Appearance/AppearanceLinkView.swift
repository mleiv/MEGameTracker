//
//  AppearanceLinkView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class AppearanceLinkView: SimpleValueDataRow {
    
    public var controller: Appearanceable? {
        didSet {
            reloadData()
        }
    }
    
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    override var heading: String? { return "Appearance" }
    override var value: String? {
        if UIWindow.isInterfaceBuilder {
            return "121.1MF.UWF.131.J6M.MDW.DM7.67W.717.1H2.157.6"
        } else {
            let code = controller?.shepard?.appearance.format()
            return code?.isEmpty == false ? code : Shepard.Appearance.sampleAppearance
        }
    }
    override var viewController: UIViewController? { return controller as? UIViewController }
    
    override func openRow(sender: UIView?) {
        onClick(sender)
    }
}


