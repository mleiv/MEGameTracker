//
//  DescriptionType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct DescriptionType: TextDataRowType {
	public typealias RowType = TextDataRow
	var view: RowType? { return row }
	public var row: TextDataRow?

	public var controller: Describable?

	public var text: String? {
		if UIWindow.isInterfaceBuilder {
			// swiftlint:disable line_length
			return "Dr Mordin Solus is a Salarian biological weapons expert whose technology may hold the key to countering Collector attacks. He is currently operation out of a medical clinic in the slums of Omega."
			// swiftlint:enable line_length
		} else {
			return controller?.descriptionMessage
		}
	}

	public var paddingSides: CGFloat = 15.0

	let defaultPaddingTop: CGFloat = 2.0
	let defaultPaddingBottom: CGFloat = 10.0
	var didSetup: Bool = false

	public var linkOriginController: UIViewController? { return controller as? UIViewController }
	var viewController: UIViewController? { return controller as? UIViewController }

	public init() {}
	public init(controller: Describable, view: TextDataRow?) {
		self.controller = controller
		self.row = view
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}

	public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
		if UIWindow.isInterfaceBuilder || !didSetup {
			if view.noPadding == true {
				view.setPadding(top: 2.0, right: 0, bottom: 2.0, left: 0)
			} else {
				view.setPadding(
					top: defaultPaddingTop,
					right: paddingSides,
					bottom: defaultPaddingBottom,
					left: paddingSides
				)
			}
		}
		didSetup = true
	}
}
