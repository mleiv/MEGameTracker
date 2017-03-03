//
//  MarkupLabel.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/17/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

// right now labels won't have clickable links, so stick to text views unless you don't want clicks
final public class MarkupLabel: IBStyledLabel, Markupable {
    
    public override var text: String? {
        didSet {
            unmarkedText = text
            applyMarkup()
        }
    }
    
    public var useAttributedText: NSAttributedString? {
        get {
            return attributedText
        }
        set {
            attributedText = newValue
        }
    }
    public var unmarkedText: String?
    
    public func applyMarkup() {
        guard !UIWindow.isInterfaceBuilder else { return }
        markupText()
        _ = markupLinks() // unclickable
        layoutIfNeeded()
    }

}
