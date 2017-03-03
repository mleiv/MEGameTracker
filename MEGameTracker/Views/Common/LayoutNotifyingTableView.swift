//
//  LayoutNotifyingTableView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public class LayoutNotifyingTableView: UITableView {

    public var onLayout: (() -> Void) = {}
    public var heightConstraint: NSLayoutConstraint?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if heightConstraint == nil {
            heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        }
        onLayout()
    }

    /// You have to wire this up yourself if you want to use it.
    /// Example: layoutTable.onLayout = layoutTable.constrainTableHeight
    public func constrainTableHeight() {
        heightConstraint?.constant = contentSize.height
        heightConstraint?.isActive = true
    }
}
