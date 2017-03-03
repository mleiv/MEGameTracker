//
//  TextDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable
open class TextDataRow: UIView {
    
     @IBInspectable open var typeName: String = "None" {
        didSet {
            if UIWindow.isInterfaceBuilder {
                setDummyDataRowType()
            }
        }
    }
    
    @IBInspectable open var showRowDivider: Bool = false
    
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
    @IBInspectable open var noPadding: Bool = false {
        didSet {
            setPadding(top: 0, right: 0, bottom: 0, left: 0)
        }
    }
    
    open weak var nib: TextDataRowNib?
    private weak var heightConstraint: NSLayoutConstraint?
    
    open var didSetup = false
    open var isSettingUp = false
    var isChangingTableHeader = false
    
    open override func layoutSubviews() {
        if !didSetup {
            isHidden = true
            setup()
        }
        super.layoutSubviews()
    }
    
    func setup() {
        guard !didSetup else { return }
        
        if nib == nil, let newNib = TextDataRowNib.loadNib() {
            insertSubview(newNib, at: 0)
            newNib.fillView(self)
            nib = newNib
        }
        
        didSetup = true
    }
    
    public func setPadding(top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        nib?.topPaddingConstraint?.constant = top
        nib?.bottomPaddingConstraint?.constant = bottom
        nib?.leadingPaddingConstraint?.constant = left
        nib?.trailingPaddingConstraint?.constant = right
        layoutIfNeeded()
    }
    
    /// reload table headers because they are finnicky.
    /// to utilize, wrap the text header in a useless extra wrapper view, so we can pop it out and into a new wrapper.
    func setupTableHeader() {
        guard !isChangingTableHeader,
            let tableView = superview as? UITableView ?? superview?.superview as? UITableView,
            tableView.tableHeaderView == self || tableView.tableHeaderView == superview
        else { return }
        
        let text = nib?.textView?.text ?? ""
        
        isChangingTableHeader = true
        
        removeFromSuperview()
        
        frame.size.height = bounds.height
        layoutIfNeeded()
        
        let newWrapper = UIView(frame: bounds)
        newWrapper.addSubview(self)
        fillView(newWrapper)
        tableView.tableHeaderView = !text.isEmpty ? newWrapper : UIView(frame: CGRect.zero)
        
        isChangingTableHeader = false
    }
    
    func setDummyDataRowType() {
        var dataRowType: TextDataRowType?
        switch typeName {
            case "Aliases": dataRowType = AliasesType()
            case "Availability": dataRowType = AvailabilityType()
            case "Unavailability": dataRowType = UnavailabilityType()
            case "Description": dataRowType = DescriptionType()
            case "OriginHint": dataRowType = OriginHintType()
            default: break
        }
        dataRowType?.view = self
        dataRowType?.setupView()
    }
}

extension TextDataRow: Bordered {
//    var borderTop: Bool { get set }
//    var borderBottom: Bool { get set }
}
 
