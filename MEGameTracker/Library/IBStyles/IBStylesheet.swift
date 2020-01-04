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
	/// Any global style changes, like tintColor.
    func applyGlobalStyles(inWindow window: UIWindow?)
}

extension IBStylesheet {
	/// (Protocol default)
	/// Initialize the style library.
	public mutating func initialize(fromWindow window: UIWindow?) {
		applyGlobalStyles(inWindow: window)
	}
}
