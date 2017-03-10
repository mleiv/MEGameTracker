//
//  AppearanceLinkType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct AppearanceLinkType: ValueDataRowType {
	public typealias RowType = ValueDataRow
	var view: RowType? { return row as? RowType }
	public var row: ValueDataRowDisplayable?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: ShepardController?
	public var onClick: ((UIButton) -> Void) = { _ in }

	public var heading: String? { return "Appearance" }
	public var value: String? {
		if UIWindow.isInterfaceBuilder {
			return "121.1MF.UWF.131.J6M.MDW.DM7.67W.717.1H2.157.6"
		} else {
			let code = controller?.shepard?.appearance.format()
			return code?.isEmpty == false ? code : Shepard.Appearance.sampleAppearance
		}
	}
	public var viewController: UIViewController? { return controller }

	public init() {}
	public init(controller: ShepardController, view: ValueDataRow?, onClick: @escaping ((UIButton) -> Void)) {
		self.controller = controller
		self.row = view as? ValueDataRowDisplayable
		self.onClick = onClick
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}
}
