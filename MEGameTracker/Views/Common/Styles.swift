//
//  Styles.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/11/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public struct Styles: IBStylesheet {
	public static var current = Styles()

    public var isInitialized: Bool = false

	public func applyGlobalStyles(inWindow window: UIWindow?) {
		window?.tintColor = MEGameTrackerColor.renegade
        let toolbarItems = UIBarButtonItem.appearance()
        toolbarItems.tintColor = MEGameTrackerColor.renegade
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
