//
//  TextDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable
final public class TextDataRow: HairlineBorderView, IBViewable {

// MARK: Inspectable
	 @IBInspectable public var typeName: String = "None" {
		didSet { setDummyDataRowType() }
	}

	@IBInspectable public var noPadding: Bool = false {
		didSet {
			setPadding(top: 0, right: 0, bottom: 0, left: 0)
		}
	}

	@IBInspectable public var isHideOnEmpty: Bool = true

// MARK: Outlets
	@IBOutlet public weak var textView: MarkupTextView?

	@IBOutlet public weak var leadingPaddingConstraint: NSLayoutConstraint?
	@IBOutlet public weak var trailingPaddingConstraint: NSLayoutConstraint?
	@IBOutlet public weak var bottomPaddingConstraint: NSLayoutConstraint?
	@IBOutlet public weak var topPaddingConstraint: NSLayoutConstraint?

	@IBOutlet public weak var rowDivider: HairlineBorderView?

// MARK: Properties
	private weak var heightConstraint: NSLayoutConstraint?

	public var didSetup = false
	public var isSettingUp = false
	var isChangingTableHeader = false

	// Protocol: IBViewable
	public var isAttachedNibWrapper = false
	public var isAttachedNib = false

// MARK: IBViewable

	override public func awakeFromNib() {
		super.awakeFromNib()
		_ = attachOrAttachedNib()
	}

	override public func prepareForInterfaceBuilder() {
		_ = attachOrAttachedNib()
		super.prepareForInterfaceBuilder()
	}

// MARK: Hide when not initialized (as though if empty)

	public override func layoutSubviews() {
		if !UIWindow.isInterfaceBuilder && !isAttachedNib && isHideOnEmpty && !didSetup {
			isHidden = true
		} else {
			setDummyDataRowType()
		}
		super.layoutSubviews()
	}

	public func setPadding(top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
		topPaddingConstraint?.constant = top
		bottomPaddingConstraint?.constant = bottom
		leadingPaddingConstraint?.constant = left
		trailingPaddingConstraint?.constant = right
        layoutIfNeeded()
	}

	/// reload table headers because they are finnicky.
	/// to utilize, wrap the text header in a useless extra wrapper view, so we can pop it out and into a new wrapper.
	func setupTableHeader() {
		guard isAttachedNib else { attachOrAttachedNib()?.setupTableHeader(); return }
		guard !isChangingTableHeader,
			let wrapperNib = self.superview,
			let superview = wrapperNib.superview,
			let tableView = superview.superview as? UITableView,
			tableView.tableHeaderView == superview
		else { return }

		isChangingTableHeader = true

		wrapperNib.removeFromSuperview()
		wrapperNib.frame.size.height = wrapperNib.bounds.height

		let newWrapper = UIView(frame: bounds)
		newWrapper.addSubview(wrapperNib)
		wrapperNib.fillView(newWrapper)

		tableView.tableHeaderView = newWrapper

		tableView.reloadData()

		isChangingTableHeader = false
	}

// MARK: Customization Options

	func setDummyDataRowType() {
		guard (isInterfaceBuilder || App.isInitializing) && !didSetup && isAttachedNibWrapper else { return }
		var dataRowType: TextDataRowType?
		switch typeName {
			case "Aliases": dataRowType = AliasesType()
			case "Availability": dataRowType = AvailabilityRowType()
			case "Unavailability": dataRowType = UnavailabilityRowType()
			case "Description": dataRowType = DescriptionType()
			case "OriginHint": dataRowType = OriginHintType()
			default: break
		}
		dataRowType?.row = self
		dataRowType?.setupView()
	}
}
