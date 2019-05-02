//
//  IBStyledThings.swift
//
//  Created by Emily Ivie on 2/25/15.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

@IBDesignable
open class IBStyledView: UIView, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                _ = styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "View" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false
    
    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        super.layoutSubviews()
        didLayout = true
    }
}

@IBDesignable
open class IBStyledLabel: UILabel, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "Label" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false
    
    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        super.layoutSubviews()
        didLayout = true
    }
}

@IBDesignable
open class IBStyledTextField: UITextField, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "TextField" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    var didLayout = false

    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        contentVerticalAlignment = .center
        _ = styler?.applyStyles()
        super.layoutSubviews()
        didLayout = true
    }
}

@IBDesignable
open class IBStyledTextView: UITextView, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "TextView" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false
    open var heightConstraint: NSLayoutConstraint?

    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        textContainer.lineFragmentPadding = 0
        if !isScrollEnabled && heightConstraint == nil {
            isScrollEnabled = true // iOS bug http://stackoverflow.com/a/33503522/5244752
            heightConstraint = heightAnchor.constraint(equalToConstant: contentSize.height)
            heightConstraint?.isActive = true
        }
        heightConstraint?.constant = contentSize.height
        super.layoutSubviews()
        didLayout = true
    }
}

@IBDesignable
open class IBStyledImageView: UIImageView, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "ImageView" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false

    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        super.layoutSubviews()
        didLayout = true
    }
}

@IBDesignable
open class IBStyledButton: UIButton, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "Button" }
    @IBInspectable
    open var tempDisabled: Bool = false
    @IBInspectable
    open var tempPressed: Bool = false
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false
    open var lastState: UIControl.State?
    
    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        let state = getState()
        if lastState != state {
            lastState = state
            styler?.applyState(state)
        }
        super.layoutSubviews()
        didLayout = true
    }
    
    override open func prepareForInterfaceBuilder() {
        if tempDisabled {
            isEnabled = false
        }
        if tempPressed {
            isHighlighted = true
        }
        let state = getState()
        lastState = state
        styler?.applyState(state)
    }
    
    /// A subset of states which IBStyles can actually handle currently. :/
    func getState() -> UIControl.State {
        if !isEnabled {
            return .disabled
        }
        if isHighlighted {
            return .highlighted
        }
        if isSelected {
            return .selected
        }
        return .normal
    }

    //button-specific:
    override open var isEnabled: Bool {
        didSet {
            if didLayout && isEnabled != oldValue {
                let state = getState()
                styler?.applyState(state)
                lastState = state
            }
        }
    }
    override open var isSelected: Bool {
        didSet {
            if didLayout && isSelected != oldValue {
                let state = getState()
                styler?.applyState(state)
                lastState = state
            }
        }
    }
    override open var isHighlighted: Bool {
        didSet {
            if didLayout && isHighlighted != oldValue {
                let state = getState()
                styler?.applyState(state)
                lastState = state
            }
        }
    }
}

@IBDesignable
open class IBStyledSegmentedControl: UISegmentedControl, IBStylable {
    @IBInspectable
    open var identifier: String? {
        didSet{
            if didLayout && oldValue != identifier {
                styler?.didApplyStyles = false
                _ = styler?.applyStyles()
            }
        }
    }
    open var defaultIdentifier: String { return "SegmentedControl" }
    open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
    open var didLayout = false
    
    public convenience init(identifier: String) {
        self.init()
        self.identifier = identifier
    }
    
    override open func layoutSubviews() {
        _ = styler?.applyStyles()
        super.layoutSubviews()
        didLayout = true
    }
}
