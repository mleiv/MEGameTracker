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

	func toggleStrikethrough(_ isOn: Bool) -> NSAttributedString {
		let attributedString = NSMutableAttributedString(attributedString: self)
        let value = NSNumber(value: isOn ? NSUnderlineStyle.single.rawValue : 0 as Int)
		attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle,
			value: value,
			range: NSRange(location: 0, length: self.length)
		)
		return attributedString
	}
}
