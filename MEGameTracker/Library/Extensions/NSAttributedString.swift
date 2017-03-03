//
//  NSAttributedString.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/12/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

extension NSAttributedString {

    func replaceText(_ search: String, withAttributedString replace: NSAttributedString) -> NSAttributedString {
        let haystack = NSString(string: self.string)
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        mutableAttributedString.replaceCharacters(in: haystack.range(of: search), with: replace)
        return mutableAttributedString
    }
    
    func toggleStrikethrough(_ on: Bool) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        attributedString.addAttribute(NSStrikethroughStyleAttributeName, value: NSNumber(value: (on ? NSUnderlineStyle.styleSingle : NSUnderlineStyle.styleNone).rawValue as Int), range: NSRange(location: 0, length: self.length))
        return attributedString
    }
}
