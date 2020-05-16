//
//  UnavailabilityRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/25/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

public struct UnavailabilityRowType: TextDataRowType {
	public typealias RowType = TextDataRow
	var view: RowType? { return row }
	public var row: TextDataRow?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: Unavailable?

	public var text: String? {
		return UIWindow.isInterfaceBuilder ? "Unavailable after Mission X" : controller?.unavailabilityMessage
	}

	let defaultPaddingTop: CGFloat = 0.0
	let defaultPaddingSides: CGFloat = 15.0
	var didSetup = false

    public var linkOriginController: UIViewController? { return controller as? UIViewController }
	var viewController: UIViewController? { return controller as? UIViewController }

	public init() {}
	public init(controller: Unavailable, view: TextDataRow?) {
		self.controller = controller
		self.row = view
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}

	public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
		if UIWindow.isInterfaceBuilder || !didSetup {
			didSetup = true
            view.backgroundColor = UIColor(named: "availabilityBackground")
            view.textView?.tintColor = UIColor(named: "availabilityLink")!
            view.textView?.textRenderingFont = UIFont.preferredFont(forTextStyle: .callout)
            view.textView?.textRenderingTextColor = UIColor(named: "availabilityLabel")!
            view.textView?.markup()
			view.textView?.textAlignment = .center
		}
		view.textView?.text = text
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
