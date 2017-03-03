//
//  ShepardOriginView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ShepardOriginView: SimpleValueAltDataRow {
    
    public var controller: ShepardController? {
        didSet {
            reloadData()
        }
    }
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    override var heading: String? { return "Origin" }
    override var value: String? {
        if UIWindow.isInterfaceBuilder {
            return "Earthborn"
        } else {
            return controller?.shepard?.origin.stringValue
        }
    }
    override var originHint: String? { return controller?.originHint }
    override var viewController: UIViewController? { return controller }
    
    override func openRow(sender: UIView?) {
        onClick(sender)
    }
}


