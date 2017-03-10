//
//  MarkupTextView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/15/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

final public class MarkupTextView: IBStyledTextView, Markupable, Linkable, UITextViewDelegate {

	public weak var linkOriginController: UIViewController?

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
//		guard !UIWindow.isInterfaceBuilder else { return }
		markupText()
		if markupLinks() > 0 {
			delegate = self // is this a recursive circle?
		}
		layoutIfNeeded()
	}

	// MARK: UITextViewDelegate

	lazy var linkHandler = LinkHandler()
	public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		DispatchQueue.main.async { self.linkHandler.openURL(URL, source: self) } // other thread?
		return false
	}

}
