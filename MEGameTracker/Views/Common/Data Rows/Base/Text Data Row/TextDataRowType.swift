//
//  TextDataRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol TextDataRowType {
	weak var row: TextDataRow? { get set }
	var text: String? { get }
	var linkOriginController: UIViewController? { get }
	var isHideOnEmpty: Bool { get }
	var showRowDivider: Bool? { get }
	mutating func setupView()
	mutating func setupView<T: TextDataRow>(type: T.Type)
	mutating func setup(view: UIView?)
	func startListeners()
}

extension TextDataRowType {
	public var text: String? { return nil }
	public var linkOriginController: UIViewController? { return nil }
	public var isHideOnEmpty: Bool { return true }
	public var showRowDivider: Bool? { return nil }

	public mutating func setupView<T: TextDataRow>(type: T.Type) {
		guard let row = row,
			let view = row.attachOrAttachedNib() as? T,
			!view.isSettingUp else { return }
		view.isSettingUp = true

		view.rowDivider?.isHidden = !(showRowDivider ?? view.showRowDivider)
		view.textView?.text = text
		view.textView?.linkOriginController = linkOriginController

		setup(view: view)

		view.setupTableHeader()
		hideEmptyView(view: row)

		view.textView?.layoutSubviews()

		if !UIWindow.isInterfaceBuilder && !view.didSetup {
			startListeners()
		}

		view.isSettingUp = false
		row.didSetup = true
	}

	public mutating func setup(view: UIView?) {}

	public mutating func open(sender: UIButton) {}

	public func hideEmptyView(view: UIView?) {
		view?.isHidden = isHideOnEmpty && !UIWindow.isInterfaceBuilder && (text ?? "").isEmpty
	}

	public func startListeners() {}
}
