//
//  ValueDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable
final public class ValueDataRow: HairlineBorderView, ValueDataRowDisplayable {

// MARK: Inspectable
	@IBInspectable public var typeName: String = "None" {
		didSet { setDummyDataRowType() }
	}
	@IBInspectable public var isHideOnEmpty: Bool = true

// MARK: Outlets
	@IBOutlet weak public var headingLabel: UILabel?
	@IBOutlet weak public var valueLabel: UILabel?
	@IBOutlet weak public var disclosureImageView: UIImageView?
	@IBOutlet weak public var button: UIButton?

	@IBAction public func buttonClicked(_ sender: UIButton) {
        print("buttonClicked")
        onClick?(sender)
    }

// MARK: Properties
	public var didSetup = false
	public var isSettingUp = false

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

	public override func layoutSubviews() {
		if !UIWindow.isInterfaceBuilder && !isAttachedNib && isHideOnEmpty && !didSetup {
			isHidden = true
		} else {
			setDummyDataRowType()
		}
		super.layoutSubviews()
	}

// mARK: Customization Options

	private func setDummyDataRowType() {
		guard (isInterfaceBuilder || App.isInitializing) && !didSetup && isAttachedNibWrapper else { return }
		var dataRowType: ValueDataRowType?
		switch typeName {
			case "Appearance": dataRowType = AppearanceLinkType()
			case "ConversationRewards": dataRowType = ConversationRewardsRowType()
			case "DecisionsListLink": dataRowType = DecisionsListLinkType()
			case "MapLink": dataRowType = MapLinkType()
			default: break
		}
		dataRowType?.row = self
		dataRowType?.setupView()
	}
}

// MARK: Spinnerable
extension ValueDataRow: Spinnerable {}
