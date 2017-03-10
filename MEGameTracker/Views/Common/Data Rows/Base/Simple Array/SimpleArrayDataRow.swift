//
//  SimpleArrayDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

/// The egneric protocol versions of this just made things more complicated.
@IBDesignable open class SimpleArrayDataRow: UIView {

	// customize (required):

	internal var heading: String? { return nil }
	internal var cellNibs: [String] { return [] }
	internal var rowCount: Int { return 0 }
	internal var originHint: String? { return nil }
	internal var viewController: UIViewController? { return nil }

	internal func setupRow(cell: UITableViewCell, indexPath: IndexPath) {}
	internal func identifierForIndexPath(_ indexPath: IndexPath) -> String { return "" }
	internal func openRow(indexPath: IndexPath, sender: UIView?) {}

	// customize (if you want to):

	internal func hideEmptyView() {
		isHidden = UIWindow.isInterfaceBuilder ? false : rowCount == 0
	}

	internal func setupTable() {}

	internal func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
	}

	internal func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
	}

	// leave alone:

	@IBInspectable open var borderTop: Bool = false {
		didSet {
			nib?.top = borderTop
		}
	}
	@IBInspectable open var borderBottom: Bool = false {
		didSet {
			nib?.bottom = borderBottom
		}
	}
	open var tableView: UITableView! { return nib?.tableView }

	internal var didSetup = false
	internal var isSettingUp = false
	internal var nib: SimpleArrayDataRowNib?

	open override func layoutSubviews() {
		if !didSetup {
			setup()
		}
		super.layoutSubviews()
	}

	internal func setup() {
		isSettingUp = true
		if nib == nil, let view = SimpleArrayDataRowNib.loadNib(heading: heading, cellNibs: cellNibs) {
			insertSubview(view, at: 0)
			view.fillView(self)
			nib = view
		}
		if let _ = nib {

			nib?.top = borderTop
			nib?.bottom = borderBottom

			tableView?.delegate = self
			tableView?.dataSource = self
			if let layoutTable = tableView as? LayoutNotifyingTableView {
				layoutTable.onLayout = layoutTable.constrainTableHeight
			}
			setupTable()

			hideEmptyView()

			if !didSetup {
				DispatchQueue.global(qos: .background).async {
					self.startListeners()
				}
			}

			didSetup = true
		}
		isSettingUp = false
	}

	deinit {
		removeListeners()
	}

	open func reloadData() {
		if rowCount > 0 {
			tableView?.reloadData()
		}
		hideEmptyView()
	}
}

extension SimpleArrayDataRow: UITableViewDataSource {

	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rowCount
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: identifierForIndexPath(indexPath)) {
			setupRow(cell: cell, indexPath: indexPath)
			return cell
		}
		return UITableViewCell()
	}
}

extension SimpleArrayDataRow: UITableViewDelegate {

	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if rowCount > (indexPath as NSIndexPath).row {
			tableView.isUserInteractionEnabled = false
			let cell = tableView.cellForRow(at: indexPath)
			openRow(indexPath: indexPath, sender: cell)
//			tableView.deselectRowAtIndexPath(indexPath, animated: true)
			tableView.isUserInteractionEnabled = true
		}
	}
}

extension SimpleArrayDataRow: UpdatingTableView {
//	public var tableView: UITableView! {}

//	public func reloadRows(rows: [NSIndexPath]) {}

//	public func insertRows(rows: [NSIndexPath]) {}

//	public func removeRows(rows: [NSIndexPath]) {}
}

extension SimpleArrayDataRow: Bordered {
//	var borderTop: Bool { get set }

//	var borderBottom: Bool { get set }
}

extension SimpleArrayDataRow: Spinnerable {
	func startParentSpinner() {
		guard !UIWindow.isInterfaceBuilder else { return }
		let parentView = (viewController?.view is UITableView) ? viewController?.view.superview : viewController?.view
		DispatchQueue.main.async {
			self.startSpinner(inView: parentView)
		}
	}
	func stopParentSpinner() {
		guard !UIWindow.isInterfaceBuilder else { return }
		let parentView = (viewController?.view is UITableView) ? viewController?.view.superview : viewController?.view
		DispatchQueue.main.async {
			self.stopSpinner(inView: parentView)
		}
	}
}
