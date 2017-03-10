//
//  IBStyles.swift
//
//  Created by Emily Ivie on 2/24/15.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

//Example:
//
//extension Styles {
//	public static var fontsList: [IBFont.Style: String] {
//		return [
//			.normal: "Avenir-Regular",
//		]
//	}

//	
//	public static var stylesList: [String: IBStyles.Properties] {
//		return [
//		"Label": [
//					.font: IBFont(style: .normal, size: .normal),
//					.textColor: UIColor.black,
//				],
//		]
//	}

//	
//	public static func applyGlobalStyles(window: UIWindow?) {
//		// apply global styles link tintColor
//	}

//}

// MARK: IBStyles

/// The base functionality for applying IBStyles to an IBStylable element.
/// Stores all styles in a static/shared struct.
public struct IBStyles {

	public typealias Properties = [IBStyles.Property: Any]
	public typealias Group = [String: IBStyles.Properties]

	public static var stylesList: [String: IBStyles.Properties] { return Styles.stylesList }
	public static var fontsList: [IBFont.Style: String] { return Styles.fontsList }
	public static var deviceKind = UIDevice.current.userInterfaceIdiom
	public static var hasAppliedGlobalStyles = false

	// MARK: IBStylePropertyName
	///
	/// All the current possible IBStyle options.
	/// Note: neither StateX or IPad|IPhoneStyles are properly visible in Interface Builder.
	///	 Use the @IBInspectable properties in IBStyledButton and IBStyledRootView to set them.
	///
	/// - inherit: expects string of IBStyle names. Applies them in order listed, with current styles taking precedence.
	/// - backgroundColor: UIColor
	/// - backgroundGradient: see IBGradient. Ex: IBGradient(direction:.Vertical, colors:[UIColor.red,UIColor.black])
	/// - borderColor: UIColor
	/// - borderWidth: Double
	/// - buttonImage: UIImage?
	/// - cornerRadius: Double
	/// - font: add new fonts to IBFont enum. This field will only accept IBFont enum values.
	/// - hasAdjustableFontSize: Bool
	/// - padding: Array (v, h) or (t, l, r, b). NOTE: Currently only works for button and textview
	/// - stateActive: an IBStyleProperties list of styles to only apply when button is active.
	/// - statePressed: an IBStyleProperties list of styles to only apply when button is pressed.
	/// - stateDisabled: an IBStyleProperties list of styles to only apply when button is disabled.
	/// - stateSelected: an IBStyleProperties list of styles to only apply when button is selected. Dunno when that is.
	/// - textAlign: NSTextAlignment
	/// - textColor: UIColor
	/// - custom: a custom string property - more risky than other options, but provides unlimited functionality
	///
	public enum Property {

		case inherit //[String]

		case backgroundColor //UIColor
		case backgroundGradient //IBGradient
		case borderColor //UIColor
		case borderWidth //Double
		case buttonImage // UIImage?
		case cornerRadius //Double
		case font //IBFont
		case hasAdjustableFontSize // Bool
		case padding // (v, h) or (t, l, r, b)
		case stateActive //IBStyleProperties
		case statePressed //IBStyleProperties
		case stateDisabled //IBStyleProperties
		case stateSelected //IBStyleProperties
		case textAlign // IBTextAlignment
		case textColor //UIColor

		case custom(String)

		static var orderedList: [Property: Int] = [
			.inherit: 0,
			.backgroundGradient: 32,
			.buttonImage: 9,
			.stateActive: 10,
			.statePressed: 11,
			.stateDisabled: 12,
			.stateSelected: 13,
			.hasAdjustableFontSize: 20,
			.font: 21,
			.textColor: 22,
			.textAlign: 23,
			.padding: 30,
			.backgroundColor: 31,
			.cornerRadius: 40,
			.borderWidth: 41,
			.borderColor: 42
		]

		public static func sort(_ first: Property, _ second: Property) -> Bool {
			return first.sortIndex < second.sortIndex
		}

		public var sortIndex: Int {
			return Property.orderedList[self] ?? 100
		}
	}

	/// Verify that all styles are the expected type.
	fileprivate static func validate(_ properties: IBStyles.Properties) {
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
					if let value = value as? IBStyles.Properties {
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

	/// Assembles a list of styles for this element, in order of priority (inherit, main, device).
	///
	/// - parameter identifier:	  the key of the element's styles
	/// - parameter to (element):	the element to be styled
	public static func apply(identifier: String, to element: UIView!) {
		if UIWindow.isInterfaceBuilder && !hasAppliedGlobalStyles {
			Styles.applyGlobalStyles(element?.window)
			hasAppliedGlobalStyles = true
		}
		if let properties = stylesList[identifier] {
			apply(properties: getAllInheritedProperties(properties), to: element)
		}
	}

	/// Recursively merges all inherited properties together.
	///
	/// - parameter properties: the list of styles
	/// - returns a Properties list of combined styles
	static func getAllInheritedProperties(_ properties: Properties) -> Properties {
		guard let inheritProperties = properties[.inherit] as? [String] else {
			return properties
		}
		var properties = properties
		properties.removeValue(forKey: .inherit)
		for name in inheritProperties {
			if let styles = stylesList[name] {
				for (key, style) in styles {
					// only add new values, otherwise let existing value have priority
					properties[key] = properties[key] ?? style
				}
			}
		}
		return getAllInheritedProperties(properties)
	}

	/// A special-case version of apply() that only applies state-specific styles.
	/// This allows for only changing specific styles rather than rewriting everything.
	///
	/// - parameter identifier:	  the key of the element's styles
	/// - parameter to (element):	the element to be styled
	/// - parameter forState:		(Optional) the UIControlState in play - normal, disabled, highlighted, or selected
	public static func apply(identifier: String, to element: UIView!, forState state: UIControlState) {
		var properties = getAllInheritedProperties(stylesList[identifier] ?? [:])
		switch state {
			case UIControlState() :
				if let p2 = properties[.stateActive] as? IBStyles.Properties {
					properties = getAllInheritedProperties(p2)
				}
			case UIControlState.disabled :
				if let p2 = properties[.stateDisabled] as? IBStyles.Properties {
					properties = getAllInheritedProperties(p2)
				}
			case UIControlState.highlighted :
				if let p2 = properties[.statePressed] as? IBStyles.Properties {
					properties = getAllInheritedProperties(p2)
				}
			case UIControlState.selected :
				if let p2 = properties[.stateSelected] as? IBStyles.Properties {
					properties = getAllInheritedProperties(p2)
				}
			default:
				return //don't do anything
		}
		apply(properties: properties, to: element, forState: state)
	}

	/// Applies a list of styles to an element
	///
	/// - parameter properties:	  the list of styles
	/// - parameter to (element):	the element to be styled
	/// - parameter forState:		(Optional) the UIControlState in play - defaults to normal
	fileprivate static func apply(
		properties: IBStyles.Properties,
		to element: UIView!,
		forState state: UIControlState = UIControlState()
	) {
		guard element != nil else { return }
		if let textView = element as? UITextView {
			textView.textContainerInset = .zero
		}
		let sortedKeys = properties.keys.sorted(by: Property.sort)
		for type in sortedKeys {
			guard let value = properties[type] else { continue }

//			let elementState: UIControlState? //for later
			switch type {
				case .backgroundColor:
					if let color = value as? UIColor {
						if let textField = element as? UITextField {
							textField.borderStyle = .none
						}
						element.layer.sublayers?.filter({
							$0 is CAGradientLayer
						}).forEach({
							$0.removeFromSuperlayer()
						})
						element.layer.backgroundColor = color.cgColor
						if let colorElement = element as? UISegmentedControl {
							colorElement.setTitleTextAttributes([
								NSForegroundColorAttributeName: color
							], for: .disabled)
						}
					}

				case .backgroundGradient:
					if let gradient = value as? IBGradient {
						let gradientView = gradient.createGradientView(element.bounds)
						element.layer.sublayers?.filter({
							$0 is CAGradientLayer
						}).forEach({
							$0.removeFromSuperlayer()
						})
						element.layer.insertSublayer(gradientView.layer, at: 0)
						gradientView.autoresizingMask = [
							UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight
						]
					}

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
							button.bringSubview(toFront: imageView)
						}
					}

				case .cornerRadius:
					element.layer.cornerRadius = CGFloat(value as? Double ?? 0.0)
					element.layer.masksToBounds = element.layer.cornerRadius > CGFloat(0)

				case .font:
					if let fontClass = value as? IBFont {
						var isScalable = true
						if let adjustableAwareElement = element as? UIContentSizeCategoryAdjusting {
							isScalable = adjustableAwareElement.adjustsFontForContentSizeCategory
						}
						if let font = fontClass.getUIFont(isScalable: isScalable, minFontSize: Styles.minFontSize) {
							if var fontElement = element as? UIContentFontSettable {
								fontElement.fontProperty = font
							}
						}
					}

				case .hasAdjustableFontSize:
					if let isAdjustableFontSize = value as? Bool {
				        if let textElement = element as? UIContentSizeCategoryAdjusting {
                            textElement.adjustsFontForContentSizeCategory = isAdjustableFontSize
                        }
                    }

                case .padding:
                    if var list = value as? [FloatLiteralType] {
                        if list.count == 1 {
                            list.append(list[0]) // left
                        }
                        if list.count == 2 {
                            list.append(list[0]) // bottom
                            list.append(list[1]) // right
                        }
                        if let button = element as? UIButton {
                            button.contentEdgeInsets = UIEdgeInsets(
								top: CGFloat(list[0]),
								left: CGFloat(list[1]),
								bottom: CGFloat(list[2]),
								right: CGFloat(list[3])
							)
                        }
                        if let textField = element as? UITextField {
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
                        if let textView = element as? UITextView {
                            textView.textContainerInset = UIEdgeInsets(
								top: CGFloat(list[0]),
								left: CGFloat(list[1]),
								bottom: CGFloat(list[2]),
								right: CGFloat(list[3])
							)
                        }
                    }

                // And now, state-specific styles:
                /*
                // currently disabled - not all styles can be set forState, so have to change dynamically on events
                // see IBStyledButton for more
                case .stateActive:
                    if let p2 = value as? IBStyles.Properties {
                        applyProperties(p2, to: element, forState: .Normal)
                    }
                case .statePressed:
                    if let p2 = value as? IBStyles.Properties {
                        applyProperties(p2, to: element, forState: .Highlighted)
                    }
                case .stateDisabled:
                    if let p2 = value as? IBStyles.Properties {
                        applyProperties(p2, to: element, forState: .Disabled)
                    }
                case .stateSelected:
                    if let p2 = value as? IBStyles.Properties {
                        applyProperties(p2, to: element, forState: .Selected)
                    }
                */

                case .textAlign:
                    if let alignment = value as? NSTextAlignment {
                        if var textElement = element as? UIContentTextAlignable {
                            textElement.textAlignmentProperty = alignment
                        }
                    }

                case .textColor:
                    if let color = value as? UIColor {
                        if let colorElement = element as? UIButton {
                            colorElement.setTitleColor(color, for: state)
                            colorElement.tintColor = UIColor.clear
                        }
                        if let colorElement = element as? UISegmentedControl {
                            colorElement.tintColor = color
                        }
                        if var colorElement = element as? UIContentColorSettable {
                            colorElement.colorProperty = color
                        }
                    }

                case .custom(let propertyKey):
                    element.setValue(value, forKey: propertyKey)

                default: break //skip the rest
            }
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

// MARK: IBStyles.Property Extensions

extension IBStyles.Property: Hashable {
    public var hashValue: Int {
        switch self {
			case (.custom(let v1)):
				return v1.hashValue
			default:
				return "\(self)".hashValue
        }
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

// MARK: Property Equatable Protocol

extension IBStyles.Property: Equatable {}
public func == (leftElement: IBStyles.Property, rightElement: IBStyles.Property) -> Bool {
    switch (leftElement, rightElement) {
		case (.custom(let v1), .custom(let v2)):
			return v1 == v2
		default:
			return "\(leftElement)" == "\(rightElement)"
    }
}
