//
//  IBStyledThings.swift
//
//  Created by Emily Ivie on 2/25/15.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

public protocol StylesInitializationListenable {
    func startListeningForStylesInitialization()
    func stopListeningForStylesInitialization()
}
extension StylesInitializationListenable where Self: UIView {
    public func startListeningForStylesInitialization() {
        NotificationCenter.default.addObserver(
            forName: IBStyleManager.stylesInitialized,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.layoutSubviews()
            }
        )
    }
    public func stopListeningForStylesInitialization() {
        NotificationCenter.default.removeObserver(
            self,
            name: IBStyleManager.stylesInitialized,
            object: nil
        )
    }
}

@IBDesignable
open class IBStyledView: UIView, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
			if didLayout && oldValue != identifier {
				styler?.didApplyStyles = false
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
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		super.layoutSubviews()
		didLayout = true
	}
}

@IBDesignable
open class IBStyledLabel: UILabel, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
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
		if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		super.layoutSubviews()
		didLayout = true
	}
}

@IBDesignable
open class IBStyledTextField: UITextField, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
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
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		super.layoutSubviews()
		didLayout = true
	}
}

@IBDesignable
open class IBStyledTextView: UITextView, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
			if didLayout && oldValue != identifier {
				styler?.didApplyStyles = false
				_ = styler?.applyStyles()
			}
		}
	}
	@IBInspectable
	open var isScrollable: Bool = false
	open var defaultIdentifier: String { return "TextView" }
	open lazy var styler: IBStyler? = { return IBStyler(element: self) }()
	open var didLayout = false
	open var heightConstraint: NSLayoutConstraint?

	public convenience init(identifier: String) {
		self.init()
		self.identifier = identifier
	}

	override open func layoutSubviews() {
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		textContainer.lineFragmentPadding = 0
		if !isScrollable && (heightConstraint == nil || heightConstraint?.isActive == true) {
			heightConstraint?.isActive = false
			sizeToFit()
			if heightConstraint == nil {
				isScrollEnabled = false
				heightConstraint = heightAnchor.constraint(equalToConstant: contentSize.height)
				heightConstraint?.priority = UILayoutPriority(rawValue: 950) // when hidden, height = 0 and this errors out.
			}
			heightConstraint?.constant = contentSize.height
			heightConstraint?.isActive = true
		}
		super.layoutSubviews()
		didLayout = true
	}
}

@IBDesignable
open class IBStyledImageView: UIImageView, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
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
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		super.layoutSubviews()
		didLayout = true
	}
}

@IBDesignable
open class IBStyledButton: UIButton, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
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
	open var lastState: UIControlState?

	public convenience init(identifier: String) {
		self.init()
		self.identifier = identifier
	}

	override open func layoutSubviews() {
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
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
	func getState() -> UIControlState {
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
open class IBStyledSegmentedControl: UISegmentedControl, IBStylable, StylesInitializationListenable {
	@IBInspectable
	open var identifier: String? {
		didSet {
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
        if styler?.applyStyles() != true {
            if !didLayout {
                startListeningForStylesInitialization()
                return
            }
        } else {
            stopListeningForStylesInitialization()
        }
		super.layoutSubviews()
		didLayout = true
	}
}
