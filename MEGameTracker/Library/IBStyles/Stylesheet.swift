//
//  Stylesheet.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/9/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public protocol Stylesheet {
	static var fontsList: [IBFont.Style: String] { get }
	static var minFontSize: CGFloat { get }
	static var stylesList: [String: IBStyles.Properties] { get }
	static func applyGlobalStyles(_ window: UIWindow?)
}

extension Stylesheet {
	public static var fontsList: [IBFont.Style: String] { return [:] }
	public static var minFontSize: CGFloat { return 10.0 }
	public static var stylesList: [String: IBStyles.Properties] { return [:] }
	public static func applyGlobalStyles(_ window: UIWindow?) {}
}

/// extend this struct in your own styles file to add your styles to the IBStyles functionality
public struct Styles: Stylesheet {}
