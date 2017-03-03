//
//  SimpleValueDataRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable open class SimpleValueDataRow: UIView {
    
    // customize (required):
    
    internal var heading: String? { return nil }
    internal var value: String? { return nil }
    internal var originHint: String? { return nil }
    internal var viewController: UIViewController? { return nil }
    
    // customize (if you want to):
    
    internal func setupRow() {
        nib?.valueLabel?.text = value
        nib?.onClick = openRow
    }
    
    internal func openRow(sender: UIView?) {}
    
    internal func hideEmptyView() {
        isHidden = UIWindow.isInterfaceBuilder ? false : (value?.isEmpty ?? true)
    }
    
    internal func startListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
    }
    
    internal func removeListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
    }
    
    
    // leave alone:
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
    
    internal var didSetup = false
    internal var isSettingUp = false
    internal var nib: SimpleValueDataRowNib?
    
    open override func layoutSubviews() {
        if !didSetup {
            setup()
        }
        super.layoutSubviews()
    }
    
    internal func setup() {
        isSettingUp = true
        if nib == nil, let view = SimpleValueDataRowNib.loadNib(heading: heading) {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
        }
        if let _ = nib {
        
            nib?.top = borderTop
            nib?.bottom = borderBottom
            nib?.rowDivider?.isHidden = !showRowDivider
            
            setupRow()
            
            hideEmptyView()
            
            DispatchQueue.global(qos: .background).async {
                self.startListeners()
            }
            
            didSetup = true
        }
        isSettingUp = false
    }
    
    deinit {
        removeListeners()
    }
    
    open func reloadData() {
        setupRow()
        hideEmptyView()
    }
}

extension SimpleValueDataRow: Bordered {
//    var borderTop: Bool { get set }
//    var borderBottom: Bool { get set }
}

extension SimpleValueDataRow: Spinnerable {
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

