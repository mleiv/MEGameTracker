//
//  DescriptionType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct DescriptionType: TextDataRowType {

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: Describable?
    public var view: TextDataRow?
    
    public var text: String? {
        if UIWindow.isInterfaceBuilder {
            return "Dr Mordin Solus is a Salarian biological weapons expert whose technology may hold the key to countering Collector attacks. He is currently operation out of a medical clinic in the slums of Omega."
        } else {
            return controller?.descriptionMessage
        }
    }
    
    public var paddingSides: CGFloat = 15.0

    let defaultPaddingTop: CGFloat = 2.0
    let defaultPaddingBottom: CGFloat = 10.0
    var didSetup: Bool = false
    
    public var linkOriginController: UIViewController? { return controller as? UIViewController }
    var viewController: UIViewController? { return controller as? UIViewController }

    public init() {}
    public init(controller: Describable, view: TextDataRow?) {
        self.controller = controller
        self.view = view
    }
    
    public mutating func setup(dataRow: TextDataRow) {
        if UIWindow.isInterfaceBuilder || !didSetup {
            if dataRow.noPadding {
                dataRow.setPadding(top: 2.0, right: 0, bottom: 2.0, left: 0)
            } else {
                dataRow.setPadding(top: defaultPaddingTop, right: paddingSides, bottom: defaultPaddingBottom, left: paddingSides)
            }
        }
        didSetup = true
    }
}


