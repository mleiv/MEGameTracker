//
//  SimpleValueAltDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable open class SimpleValueAltDataRow: SimpleValueDataRow {
    
    // customize (required):
    
     @IBInspectable open var hideHeadingOnCompactView: Bool = false
    
    // leave alone:
    
    override func setup() {
        isSettingUp = true
        if nib == nil, let view = SimpleValueAltDataRowNib.loadNib(heading: heading) {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
        }
        super.setup()
    }
    
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        configureViewForSizeClass()
    }
    
    var lastHorizontalSizeClass: UIUserInterfaceSizeClass?

    func configureViewForSizeClass() {
        if lastHorizontalSizeClass != .regular && nib?.traitCollection.horizontalSizeClass == .regular {
            configureViewForRegularSizeClass()
            lastHorizontalSizeClass = .regular
        } else if lastHorizontalSizeClass != .compact && nib?.traitCollection.horizontalSizeClass == .compact {
            configureViewForCompactSizeClass()
            lastHorizontalSizeClass = .compact
        }
    }
    
    func configureViewForRegularSizeClass() {
        nib?.headingLabel?.isHidden = false
    }
    
    func configureViewForCompactSizeClass() {
        nib?.headingLabel?.isHidden = hideHeadingOnCompactView
    }
}
