//
//  IBStyleManager.swift
//
//  Created by Emily Ivie on 2/24/15.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

// swiftlint:disable file_length

/// The base functionality for applying IBStyles to an IBStylable element.
/// Stores all styles in a static/shared struct.
/// Call its applyGlobalStyles() in AppDelegate initialization.
///
/// Example:
///
/// ```swift
/// struct Styles: IBStylesheet {
///    public static var current = Styles()
///    public var fonts: [IBFont.Style: String] {
///        return [:]
///    }
///    public var styles: [String: IBStyleProperty.List] {
///        return [:]
///    }
///    func applyGlobalStyles(inWindow window: UIWindow?) {
///        // do stuff
///    }
/// }
public struct IBStyleManager {
    public static let stylesInitialized = Notification.Name(rawValue: "stylesInitialized")
	public static var current = IBStyleManager()
	public var stylesheet: IBStylesheet?
	public var deviceKind = UIDevice.current.userInterfaceIdiom
}

extension IBStyleManager {

	/// Assembles a list of styles for this element, in order of priority (inherit, main, device).
	///
	/// - parameter identifier:	  the key of the element's styles
	/// - parameter to (element):	the element to be styled
	public func apply(
		identifier: String,
		to element: UIView?
	) {
		if let properties = stylesheet?.styles[identifier] {
			apply(properties: getAllInheritedProperties(properties), to: element)
		}
	}

	/// A special-case version of apply() that only applies state-specific styles.
	/// This allows for only changing specific styles rather than rewriting everything.
	///
	/// - parameter identifier:	  the key of the element's styles
	/// - parameter to (element):	the element to be styled
	/// - parameter forState:		(Optional) the UIControlState in play - normal, disabled, highlighted, or selected
	public func apply(
		identifier: String,
		to element: UIView?,
		forState state: UIControl.State
	) {
		var properties = getAllInheritedProperties(stylesheet?.styles[identifier] ?? [:])
		switch state {
			case UIControl.State() :
				if let p2 = properties[.stateActive] as? IBStyleProperty.List {
					properties = getAllInheritedProperties(p2)
				}
			case UIControl.State.disabled :
				if let p2 = properties[.stateDisabled] as? IBStyleProperty.List {
					properties = getAllInheritedProperties(p2)
				}
			case UIControl.State.highlighted :
				if let p2 = properties[.statePressed] as? IBStyleProperty.List {
					properties = getAllInheritedProperties(p2)
				}
			case UIControl.State.selected :
				if let p2 = properties[.stateSelected] as? IBStyleProperty.List {
					properties = getAllInheritedProperties(p2)
				}
			default:
				return //don't do anything
		}
		apply(properties: properties, to: element, forState: state)
	}

	/// Verify that all styles are the expected type.
	fileprivate func validate(_ properties: IBStyleProperty.List) {
		for (type, value) in properties {
			switch type {
				case .inherit:
					assert(value as? [String] != nil)
				case .backgroundColor:
					assert(value as? UIColor != nil)
				case .backgroundGradient:
					assert(value as? IBGradient != nil) //what if I add other gradients?
				case .borderColor:
					assert(value as? UIColor != nil)
				case .borderWidth:
					assert(value as? Double != nil)
				case .buttonImage:
					assert(value as? UIImage != nil)
				case .cornerRadius:
					assert(value as? Double != nil)
				case .font:
					assert(value as? IBFont != nil)
				case .hasAdjustableFontSize:
					assert(value as? Bool != nil)
				case .padding:
					let list = value as? [FloatLiteralType]
					assert(list?.count == 1 || list?.count == 2 || list?.count == 4)
				case .stateActive: fallthrough
				case .statePressed: fallthrough
				case .stateDisabled: fallthrough
				case .stateSelected:
					if let value = value as? IBStyleProperty.List {
						validate(value)
					} else {
						assert(false)
					}
				case .textAlign:
					assert(value as? NSTextAlignment != nil)
				case .textColor:
					assert(value as? UIColor != nil)
				case .custom(_): break // no validation
			}
		}
	}

	/// Recursively merges all inherited properties together.
	///
	/// - parameter properties: the list of styles
	/// - returns a Properties list of combined styles
	fileprivate func getAllInheritedProperties(_ properties: IBStyleProperty.List) -> IBStyleProperty.List {
		guard let inheritProperties = properties[.inherit] as? [String] else {
			return properties
		}
		var properties = properties
		properties.removeValue(forKey: .inherit)
		for name in inheritProperties {
			if let styles = stylesheet?.styles[name] {
				for (key, style) in styles {
					// only add new values, otherwise let existing value have priority
					properties[key] = properties[key] ?? style
				}
			}
		}
		return getAllInheritedProperties(properties)
	}

	/// Applies a list of styles to an element
	///
	/// - parameter properties:	  the list of styles
	/// - parameter to (element):	the element to be styled
	/// - parameter forState:		(Optional) the UIControlState in play - defaults to normal
	fileprivate func apply(
		properties: IBStyleProperty.List,
		to element: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard let element = element else { return }
		if let textView = element as? UITextView {
			textView.textContainerInset = .zero
		}
		let sortedKeys = properties.keys.sorted(by: IBStyleProperty.sort)
		for type in sortedKeys {
			guard let value = properties[type] else { continue }
			switch type {
				case .backgroundColor:
					change(backgroundColor: value as? UIColor, inView: element, forState: state)
				case .backgroundGradient:
					change(backgroundGradient: value as? IBGradient, inView: element, forState: state)
				case .borderColor:
					if let color = value as? UIColor {
						element.layer.borderColor = (color).cgColor
					}
				case .borderWidth:
					element.layer.borderWidth = CGFloat(value as? Double ?? 0.0)
				case .buttonImage:
					if let image = value as? UIImage, let button = element as? UIButton {
						button.setImage(image, for: state)
						if let imageView = button.imageView {
							button.bringSubviewToFront(imageView)
						}
					}
				case .cornerRadius:
					element.layer.cornerRadius = CGFloat(value as? Double ?? 0.0)
					element.layer.masksToBounds = element.layer.cornerRadius > CGFloat(0)
				case .font:
					change(fontClass: value as? IBFont, inView: element, forState: state)
				case .hasAdjustableFontSize:
					if let isAdjustableFontSize = value as? Bool {
				        if let textElement = element as? UIContentSizeCategoryAdjusting {
                            textElement.adjustsFontForContentSizeCategory = isAdjustableFontSize
                        }
                    }
                case .padding:
					change(paddingList: value as? [FloatLiteralType], inView: element)
                case .textAlign:
                    if let alignment = value as? NSTextAlignment {
                        if var textElement = element as? UIContentTextAlignable {
                            textElement.textAlignmentProperty = alignment
                        }
                    }
                case .textColor:
					change(textColor: value as? UIColor, inView: element, forState: state)
                case .custom(let propertyKey):
                    element.setValue(value, forKey: propertyKey)
                default: break //skip the rest
            }
        }
    }
}

// MARK: Specific IBStylable Types
extension IBStyleManager {

	/// Changes the text color of the specified view.
	fileprivate func change(
		textColor color: UIColor?,
		inView view: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard let color = color, let view = view else { return }
		if let colorElement = view as? UIButton {
			colorElement.setTitleColor(color, for: state)
			colorElement.tintColor = UIColor.clear
		}
		if let colorElement = view as? UISegmentedControl {
			colorElement.tintColor = color
		}
		if var colorElement = view as? UIContentColorSettable {
			colorElement.colorProperty = color
		}
	}

	/// Changes the background color of the specified view.
	fileprivate func change(
		backgroundColor color: UIColor?,
		inView view: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard let color = color, let view = view else { return }
		if let textField = view as? UITextField {
			textField.borderStyle = .none
		}
		view.layer.sublayers?.filter({
			$0 is CAGradientLayer
		}).forEach({
			$0.removeFromSuperlayer()
		})
		view.layer.backgroundColor = color.cgColor
		if let colorElement = view as? UISegmentedControl {
			colorElement.setTitleTextAttributes([
				NSAttributedString.Key.foregroundColor: color
			], for: .disabled)
		}
	}

	/// Changes the background gradient of the specified view.
	fileprivate func change(
		backgroundGradient gradient: IBGradient?,
		inView view: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard let gradient = gradient, let view = view else { return }
		let gradientView = gradient.createGradientView(view.bounds)
		view.layer.sublayers?.filter({
			$0 is CAGradientLayer
		}).forEach({
			$0.removeFromSuperlayer()
		})
		view.layer.insertSublayer(gradientView.layer, at: 0)
		gradientView.autoresizingMask = [
			UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight
		]
	}

	/// Changes the font/scaled size of the specified view.
	fileprivate func change(
		fontClass: IBFont?,
		inView view: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard let fontClass = fontClass, let view = view else { return }
		if let font = fontClass.getUIFont(),
            var fontElement = view as? UIContentFontSettable {
            fontElement.fontProperty = font
		}
	}

	/// Changes the padding of the specified view.
	fileprivate func change(
		paddingList list: [FloatLiteralType]?,
		inView view: UIView?,
		forState state: UIControl.State = UIControl.State()
	) {
		guard var list = list, let view = view else { return }
		if list.count == 1 {
			list.append(list[0]) // left
		}
		if list.count == 2 {
			list.append(list[0]) // bottom
			list.append(list[1]) // right
		}
		if let button = view as? UIButton {
			button.contentEdgeInsets = UIEdgeInsets(
				top: CGFloat(list[0]),
				left: CGFloat(list[1]),
				bottom: CGFloat(list[2]),
				right: CGFloat(list[3])
			)
		}
		if let textField = view as? UITextField {
			let widthOneHeightFrame = CGRect(
				x: 0.0,
				y: 0.0,
				width: CGFloat(list[1]),
				height: textField.bounds.height
			)
			let leftPadding = UIView(frame: widthOneHeightFrame)
			textField.leftView = leftPadding
			textField.leftViewMode = .always
		}
		if let textView = view as? UITextView {
			textView.textContainerInset = UIEdgeInsets(
				top: CGFloat(list[0]),
				left: CGFloat(list[1]),
				bottom: CGFloat(list[2]),
				right: CGFloat(list[3])
			)
		}
	}
}

// MARK: UIContentFontSettable Protocol
public protocol UIContentFontSettable {
    var fontProperty: UIFont? { get set }
}
extension UILabel: UIContentFontSettable {
    public var fontProperty: UIFont? {
        get { return font }
        set { font = newValue }
    }
}
extension UITextView: UIContentFontSettable {
    public var fontProperty: UIFont? {
        get { return font }
        set { font = newValue }
    }
}
extension UITextField: UIContentFontSettable {
    public var fontProperty: UIFont? {
        get { return font }
        set { font = newValue }
    }
}

// MARK: UIContentColorSettable Protocol
public protocol UIContentColorSettable {
    var colorProperty: UIColor? { get set }
}
extension UILabel: UIContentColorSettable {
    public var colorProperty: UIColor? {
        get { return textColor }
        set { textColor = newValue }
    }
}
extension UITextView: UIContentColorSettable {
    public var colorProperty: UIColor? {
        get { return textColor }
        set { textColor = newValue }
    }
}
extension UITextField: UIContentColorSettable {
    public var colorProperty: UIColor? {
        get { return textColor }
        set { textColor = newValue }
    }
}

// MARK: UIContentTextAlignable Protocol
public protocol UIContentTextAlignable {
    var textAlignmentProperty: NSTextAlignment? { get set }
}
extension UILabel: UIContentTextAlignable {
    public var textAlignmentProperty: NSTextAlignment? {
        get { return textAlignment }
        set { textAlignment = newValue ?? .natural }
    }
}
extension UITextView: UIContentTextAlignable {
    public var textAlignmentProperty: NSTextAlignment? {
        get { return textAlignment }
        set { textAlignment = newValue ?? .natural }
    }
}
extension UITextField: UIContentTextAlignable {
    public var textAlignmentProperty: NSTextAlignment? {
        get { return textAlignment }
        set { textAlignment = newValue ?? .natural }
    }
}
// swiftlint:enable file_length
