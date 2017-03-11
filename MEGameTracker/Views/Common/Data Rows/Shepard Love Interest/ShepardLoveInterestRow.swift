//
//  ShepardLoveInterestView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable
final public class ShepardLoveInterestRow: HairlineBorderView, ValueDataRowDisplayable {

// MARK: Inspectable
	@IBInspectable open var typeName: String = "None" {
		didSet { setDummyDataRowType() }
	}
	@IBInspectable open var showRowDivider: Bool = false
	@IBInspectable open var isHideOnEmpty: Bool = true

// MARK: Outlets
	@IBOutlet weak public var loveInterestImageView: UIImageView?

	@IBOutlet weak public var headingLabel: IBStyledLabel?
	@IBOutlet weak public var valueLabel: IBStyledLabel?
	@IBOutlet weak public var disclosureImageView: UIImageView?
	@IBOutlet weak public var button: UIButton?

	@IBOutlet weak public var rowDivider: HairlineBorderView?

	@IBAction public func buttonClicked(_ sender: UIButton) { onClick?(sender) }

// MARK: Properties
	open var didSetup = false
	open var isSettingUp = false

	// Protocol: IBViewable
	public var isAttachedNibWrapper = false
	public var isAttachedNib = false

	public var onClick: ((UIButton) -> Void)?

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

	open override func layoutSubviews() {
		if !UIWindow.isInterfaceBuilder && !isAttachedNib && isHideOnEmpty && !didSetup {
			isHidden = true
		} else {
			setDummyDataRowType()
		}
		super.layoutSubviews()
	}

// MARK: Customization Options 

	private func setDummyDataRowType() {
		guard (isInterfaceBuilder || App.isInitializing) && !didSetup && isAttachedNibWrapper else { return }
		var dataRowType = ShepardLoveInterestRowType()
		dataRowType.row = self
		dataRowType.setupView()
	}
}
