//
//  ShepardClassRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct ShepardClassRowType: ValueDataRowType {
	public typealias RowType = ValueAltDataRow
	var view: RowType? { return row as? RowType }
	public var row: ValueDataRowDisplayable?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: ShepardController?
	public var onClick: ((UIButton) -> Void) = { _ in }

	public var heading: String? { return "Class" }
	public var value: String? {
		return (UIWindow.isInterfaceBuilder || App.isInitializing)
			? "Soldier" : controller?.shepard?.classTalent.stringValue
	}
	public var originHint: String? { return controller?.originHint }
	public var viewController: UIViewController? { return controller }

	public init() {}
	public init(controller: ShepardController, view: ValueAltDataRow?, onClick: @escaping ((UIButton) -> Void)) {
		self.controller = controller
		self.row = view as? ValueDataRowDisplayable
		self.onClick = onClick
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}

	public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
		view.headingLabel?.text = heading?.isEmpty == false ? "\(heading ?? ""): " : nil
		view.valueLabel?.text = UIWindow.isInterfaceBuilder ? value ?? "Value" : value
	}
}
