//
//  TextDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable
open class TextDataRow: HairlineBorderView, IBViewable {
    
// MARK: Inspectable
     @IBInspectable open var typeName: String = "None" {
        didSet { setDummyDataRowType() }
    }
	
    @IBInspectable open var noPadding: Bool = false {
        didSet {
            setPadding(top: 0, right: 0, bottom: 0, left: 0)
        }
    }
    
    @IBInspectable open var showRowDivider: Bool = false
    @IBInspectable open var isHideOnEmpty: Bool = true
	
// MARK: Outlets
    @IBOutlet open weak var textView: MarkupTextView?
    
    @IBOutlet open weak var leadingPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var trailingPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var bottomPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var topPaddingConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var rowDivider: HairlineBorderView?
    
// MARK: Properties
    private weak var heightConstraint: NSLayoutConstraint?
    
    open var didSetup = false
    open var isSettingUp = false
    var isChangingTableHeader = false
	
	// Protocol: IBViewable
	public var isLoadedNib = false
	public var isLoadedAttachedNib = false
    
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
    
    public func setPadding(top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        topPaddingConstraint?.constant = top
        bottomPaddingConstraint?.constant = bottom
        leadingPaddingConstraint?.constant = left
        trailingPaddingConstraint?.constant = right
        layoutIfNeeded()
    }
    
    /// reload table headers because they are finnicky.
    /// to utilize, wrap the text header in a useless extra wrapper view, so we can pop it out and into a new wrapper.
    func setupTableHeader(view: UIView?) {
		guard isLoadedAttachedNib else { return }
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
    
    func setDummyDataRowType() {
        guard isInterfaceBuilder && !isLoadedAttachedNib else { return }
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
