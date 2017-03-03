//
//  UnavailabilityType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/25/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

public struct UnavailabilityType: TextDataRowType {

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: Unavailable?
    public var view: TextDataRow?
    
    public var text: String? {
        return UIWindow.isInterfaceBuilder ? "Unavailable after Mission X" : controller?.unavailabilityMessage
    }

    let defaultPaddingTop: CGFloat = 0.0
    let defaultPaddingSides: CGFloat = 15.0
    var didSetup = false
    
    var viewController: UIViewController? { return controller as? UIViewController }

    public init() {}
    public init(controller: Unavailable, view: TextDataRow?) {
        self.controller = controller
        self.view = view
    }
    
    public mutating func setup(dataRow: TextDataRow) {
        if UIWindow.isInterfaceBuilder || !didSetup {
            didSetup = true
            dataRow.nib?.backgroundColor = UIColor.darkGray
            dataRow.nib?.textView?.identifier = "Caption.DisabledOppositeColor.MediumItalic"
            dataRow.nib?.textView?.linkTextAttributes = [
                NSForegroundColorAttributeName: Styles.Colors.linkOnBlackColor
            ]
            dataRow.nib?.textView?.textAlignment = .center
        }
        dataRow.nib?.textView?.text = text
    }
}


