//
//  RadioOptionRowView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/29/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final public class RadioOptionRowView: UIView {

    @IBInspectable public var text: String?

    @IBInspectable public var showRowDivider: Bool = false
    
    @IBInspectable public var borderTop: Bool = false {
        didSet {
            nib?.top = borderTop
        }
    }
    @IBInspectable public var borderBottom: Bool = false {
        didSet {
            nib?.bottom = borderBottom
        }
    }
    
    public var heading: String?
    public var isOn: Bool = false {
        didSet {
            nib?.radioButton?.toggle(isOn: isOn)
        }
    }
    
    public var onChange: ((_ sender: UIView?) -> Void) = { _ in }
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    var value: String? { return text?.isEmpty == false ? text : heading }
    
    var didSetup = false
    var nib: RadioOptionRowNib?
    
    public override func layoutSubviews() {
        if !didSetup {
            setup()
        }
        super.layoutSubviews()
    }
    
    func setup() {
        if nib == nil, let view = RadioOptionRowNib.loadNib() {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
        }
        if let view = nib {
            view.rowDivider?.isHidden = !showRowDivider
            view.onChange = onChange
            view.onClick = onClick
            
            setupRow()
            
            didSetup = true
        }
    }
    
    internal func setupRow() {
        nib?.headingLabel?.text = value
        nib?.radioButton?.toggle(isOn: isOn)
        hideEmptyView()
    }
    
    internal func hideEmptyView() {
        isHidden = UIWindow.isInterfaceBuilder ? false : (value?.isEmpty ?? true)
    }
}


