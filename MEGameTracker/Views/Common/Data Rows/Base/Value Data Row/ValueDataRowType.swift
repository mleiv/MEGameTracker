//
//  ValueDataRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/7/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public protocol ValueDataRowType {
//	associatedtype ValueDataRow: ValueDataRowDisplayable
//	weak var view: ValueDataRow? { get set }
	// ... because Swift generics still suck
	weak var row: ValueDataRowDisplayable? { get set }
	var heading: String? { get }
	var value: String? { get }
	var viewController: UIViewController? { get }
	var isHideOnEmpty: Bool { get }
	var showRowDivider: Bool? { get }
	var onClick: ((UIButton) -> Void) { get }
	mutating func setupView()
	mutating func setupView<T: ValueDataRowDisplayable>(type: T.Type)
	mutating func setup(view: UIView?)
	func startListeners()
}

extension ValueDataRowType {
	public var heading: String? { return nil }
	public var value: String? { return nil }
	public var viewController: UIViewController? { return nil }
	public var isHideOnEmpty: Bool { return true }
	public var showRowDivider: Bool? { return nil }

	public mutating func setupView<T: ValueDataRowDisplayable>(type: T.Type) {
		guard let row = row as? T,
			let view = row.attachOrAttachedNib(),
			!view.isSettingUp else { return }
		view.isSettingUp = true

		view.rowDivider?.isHidden = !(showRowDivider ?? row.showRowDivider)
		view.onClick = onClick
		view.headingLabel?.text = heading
		view.valueLabel?.text = value

		setup(view: view as? UIView)

		hideEmptyView(view: row as? UIView)
		
		if !UIWindow.isInterfaceBuilder && !view.didSetup {
			startListeners()
		}

//		(view as? UIView)?.layoutIfNeeded()

		view.isSettingUp = false
		row.didSetup = true
	}

	public mutating func setup(view: UIView?) {}

	public mutating func open(sender: UIButton) {}

	public func hideEmptyView(view: UIView?) {
		view?.isHidden = isHideOnEmpty && !UIWindow.isInterfaceBuilder && (value ?? "").isEmpty
	}

	public func startListeners() {}
}
