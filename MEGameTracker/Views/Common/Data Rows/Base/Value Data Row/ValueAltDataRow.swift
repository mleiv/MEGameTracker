//
//  ValueAltDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable
open class ValueAltDataRow: HairlineBorderView, ValueDataRowDisplayable {
	
// MARK: Inspectable
	@IBInspectable open var typeName: String = "None" {
        didSet { setDummyDataRowType() }
    }
	@IBInspectable open var hideHeadingOnCompactView: Bool = false
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
	
    var lastHorizontalSizeClass: UIUserInterfaceSizeClass?
	
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
        configureViewForSizeClass()
        super.layoutSubviews()
    }

    internal func configureViewForSizeClass() {
        if lastHorizontalSizeClass != .regular && traitCollection.horizontalSizeClass == .regular {
            configureViewForRegularSizeClass()
            lastHorizontalSizeClass = .regular
        } else if lastHorizontalSizeClass != .compact && traitCollection.horizontalSizeClass == .compact {
            configureViewForCompactSizeClass()
            lastHorizontalSizeClass = .compact
        }
    }
    
    internal func configureViewForRegularSizeClass() {
        headingLabel?.isHidden = false
    }
    
    internal func configureViewForCompactSizeClass() {
        headingLabel?.isHidden = hideHeadingOnCompactView
    }
	
    private func setDummyDataRowType() {
        guard isInterfaceBuilder && !isLoadedAttachedNib else { return }
        var dataRowType: ValueDataRowType?
        switch typeName {
            case "Class": dataRowType = ShepardClassRowType()
            case "Origin": dataRowType = ShepardOriginRowType()
            case "Reputation": dataRowType = ShepardReputationRowType()
			case "DecisionsListLink": dataRowType = DecisionsListLinkType()
            default: break
        }
        dataRowType?.row = self
        dataRowType?.setupView()
    }
}

// MARK: Spinnerable
extension ValueAltDataRow: Spinnerable {}