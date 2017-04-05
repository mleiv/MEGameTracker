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
			guard !isInsideSetter else { return }
			unmarkedText = text
			applyMarkup()
		}
	}

	public var useAttributedText: NSAttributedString? {
		get { return attributedText }
		set {
			isInsideSetter = true
			attributedText = newValue
			// does not apply styles unless explicitly run in main queue,
			//    which dies because already in main queue.
			isInsideSetter = false
		}
	}
	public var unmarkedText: String?
	public var isInsideSetter = false

	/// I expect this to only be called on main/UI dispatch queue, otherwise bad things will happen.
	/// I can't dispatch to main async or layout does not render properly.
	public func applyMarkup() {
		guard !UIWindow.isInterfaceBuilder else { return }
		markup()
		delegate = self
	}

	// MARK: UITextViewDelegate

	lazy var linkHandler = LinkHandler()
	public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		DispatchQueue.main.async { self.linkHandler.openURL(URL, source: self) } // other thread?
		return false
	}

}
