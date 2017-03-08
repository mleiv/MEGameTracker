//
//  ValueDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable
open class ValueDataRow: HairlineBorderView, ValueDataRowDisplayable {
	
// MARK: Inspectable
	@IBInspectable open var typeName: String = "None" {
        didSet { setDummyDataRowType() }
    }
    @IBInspectable open var showRowDivider: Bool = false
    @IBInspectable open var isHideOnEmpty: Bool = true
	
// MARK: Outlets
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
	public var isLoadedNib = false
	public var isLoadedAttachedNib = false
	
	public var onClick: ((UIButton)->Void)?
	
// MARK: Do not change
	
	// attachedNib
	
	/// Blocks IBViewable from overriding nib view
	open override func prepareForInterfaceBuilder() {
		if superview == nil {
			isLoadedAttachedNib = true
		}
		super.prepareForInterfaceBuilder()
	}
	
    open override func layoutSubviews() {
        if !UIWindow.isInterfaceBuilder && !isLoadedAttachedNib && isHideOnEmpty && !didSetup {
            isHidden = true
        }
        super.layoutSubviews()
    }
	
    private func setDummyDataRowType() {
        guard isInterfaceBuilder && !isLoadedAttachedNib else { return }
        var dataRowType: ValueDataRowType?
        switch typeName {
            case "Appearance": dataRowType = AppearanceLinkType()
            case "ConversationRewards": dataRowType = ConversationRewardsRowType()
            case "DecisionListLink": dataRowType = DecisionsListLinkType()
			case "MapLink": dataRowType = MapLinkType()
            default: break
        }
        dataRowType?.row = self
        dataRowType?.setupView()
    }
}

// MARK: Spinnerable
extension ValueDataRow: Spinnerable {}

