//
//  OriginHintType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct OriginHintType: TextDataRowType {
	public typealias RowType = TextDataRow
	var view: RowType? { return row }
    public var row: TextDataRow?

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: OriginHintable?
    
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
        self.row = view
    }
	
	public mutating func setupView() {
		setupView(type: RowType.self)
	}

    public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
        if !view.didSetup {
//            view.backgroundColor = UIColor.red
            view.textView?.identifier = "Caption.DisabledColor"
            view.bottomPaddingConstraint?.constant = defaultPaddingBottom
            view.leadingPaddingConstraint?.constant = defaultPaddingSides
            view.trailingPaddingConstraint?.constant = defaultPaddingSides
        }
    }
}


