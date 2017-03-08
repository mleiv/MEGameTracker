//
//  AvailabilityRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct AvailabilityRowType: TextDataRowType {
	public typealias RowType = TextDataRow
	var view: RowType? { return row }
    public var row: TextDataRow?

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: Available?
    
    public var text: String? {
        return UIWindow.isInterfaceBuilder ? "Unavailable in Game 1" : controller?.availabilityMessage
    }

    let defaultPaddingTop: CGFloat = 0.0
    let defaultPaddingSides: CGFloat = 15.0
    var didSetup = false
    
    var viewController: UIViewController? { return controller as? UIViewController }

    public init() {}
    public init(controller: Available, view: TextDataRow?) {
        self.controller = controller
        self.row = view
    }
	
	public mutating func setupView() {
		setupView(type: RowType.self)
	}
    
    public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
        if UIWindow.isInterfaceBuilder || !didSetup {
            didSetup = true
            view.backgroundColor = UIColor.black
            view.textView?.identifier = "Caption.DisabledOppositeColor.MediumItalic"
            view.textView?.linkTextAttributes = [
                NSForegroundColorAttributeName: Styles.Colors.linkOnBlackColor
            ]
            view.textView?.textAlignment = .center
        }
        view.textView?.text = text
    }
}


