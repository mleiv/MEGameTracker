//
//  OriginHintType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct OriginHintType: TextDataRowType {

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: OriginHintable?
    public var view: TextDataRow?
    
    public var overrideOriginHint: String?
    public var overrideOriginPrefix: String?
    
    public var text: String? {
        if let originHint = overrideOriginHint ??  controller?.originHint , !originHint.isEmpty {
            if let originPrefix = overrideOriginPrefix ?? controller?.originPrefix , !originPrefix.isEmpty {
                return "\(originPrefix): \(originHint)"
            } else {
                return originHint
            }
        } else if UIWindow.isInterfaceBuilder {
            return "From: Sahrabarik"
        }
        return nil
    }
    
    var viewController: UIViewController? { return controller as? UIViewController }
    
    let defaultPaddingBottom: CGFloat = 5.0
    let defaultPaddingSides: CGFloat = 10.0
    
    public init() {}
    public init(controller: OriginHintable, view: TextDataRow?) {
        self.controller = controller
        self.view = view
    }

    public func setup(dataRow: TextDataRow) {
        if !dataRow.didSetup {
            dataRow.nib?.backgroundColor = UIColor.red
            dataRow.nib?.textView?.identifier = "Caption.DisabledColor"
            dataRow.nib?.bottomPaddingConstraint?.constant = defaultPaddingBottom
            dataRow.nib?.leadingPaddingConstraint?.constant = defaultPaddingSides
            dataRow.nib?.trailingPaddingConstraint?.constant = defaultPaddingSides
        }
    }
}


