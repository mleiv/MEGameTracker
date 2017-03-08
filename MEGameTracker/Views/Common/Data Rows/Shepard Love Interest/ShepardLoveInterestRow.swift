//
//  ShepardLoveInterestView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

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
	public var isLoadedNib = false
	public var isLoadedAttachedNib = false
	
	public var onClick: ((UIButton)->Void)?
	
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
        var dataRowType = ShepardLoveInterestRowType()
        dataRowType.row = self
        dataRowType.setupView()
    }
}


