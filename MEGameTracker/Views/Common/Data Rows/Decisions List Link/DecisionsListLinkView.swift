//
//  DecisionsListLinkView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/19/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class DecisionsListLinkView: SimpleValueDataRow {
    
    public var controller: DecisionsListLinkable? {
        didSet {
            reloadData()
        }
    }
    
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    override var heading: String? { return "Decisions" }
//    override var value: String? {
//        
//    }
    override var viewController: UIViewController? { return controller as? UIViewController }
    
    override func hideEmptyView() {}
    
    override func openRow(sender: UIView?) {
        onClick(sender)
    }
}


