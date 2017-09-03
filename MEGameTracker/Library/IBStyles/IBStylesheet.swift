//
//  Stylesheet.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/9/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

/// Describes a stylesheet which can be attached to IBStyleManager.
public protocol IBStylesheet {

	/// A list of the font styles available.
	var fonts: [IBFont.Style: String] { get }

	/// The smalled font size allowed, regardless of scaling.
	var minFontSize: CGFloat { get }

	/// A list of stylesheet identifiers and styles.
	var styles: [String: IBStyleProperty.List] { get }

	var isInitialized: Bool { get set }

	/// Any global style changes, like tintColor.
    func applyGlobalStyles(inWindow window: UIWindow?)
}

extension IBStylesheet {

	/// (Protocol default)
	/// A list of the font styles available.
	public var fonts: [IBFont.Style: String] { return [:] }

	/// (Protocol default)
	/// The smalled font size allowed, regardless of scaling.
	public var minFontSize: CGFloat { return 10.0 }

	/// (Protocol default)
	/// A list of stylesheet identifiers and styles.
	public var styles: [String: IBStyleProperty.List] { return [:] }

	/// (Protocol default)
	/// Initialize the style library.
	public mutating func initialize(fromWindow window: UIWindow?) {
		IBStyleManager.current.stylesheet = self
		applyGlobalStyles(inWindow: window)
        IBStyleManager.current.stylesheet?.isInitialized = true
        NotificationCenter.default.post(
            name: IBStyleManager.stylesInitialized,
            object: nil,
            userInfo: nil
        )
	}
}
