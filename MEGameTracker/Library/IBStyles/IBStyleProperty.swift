//
//  IBStyleProperty.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/10/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

/// All the current possible IBStyle options.
/// Note: neither StateX or IPad|IPhoneStyles are properly visible in Interface Builder.
///	 Use the @IBInspectable properties in IBStyledButton and IBStyledRootView to set them.
public enum IBStyleProperty {

	public typealias List = [IBStyleProperty: Any]
	public typealias Group = [String: List]

	/// Expects string of IBStyle names. Applies them in order listed, with current styles taking precedence.
	case inherit //[String]

	/// UIColor
	case backgroundColor
	/// IBGradient. Ex: IBGradient(direction:.Vertical, colors:[UIColor.red,UIColor.black]).
	case backgroundGradient
	/// UIColor
	case borderColor
	/// Double
	case borderWidth
	/// UIImage?
	case buttonImage
	/// Double
	case cornerRadius
	/// IBFont. Add new fonts to IBFont enum. This field will only accept IBFont enum values.
	case font
	/// Bool
	case hasAdjustableFontSize
	/// Array (v, h) or (t, l, r, b). NOTE: Currently only works for button and textview.
	case padding
	/// IBStyleProperty.List to only apply when button is active.
	case stateActive
	/// IBStyleProperty.List to only apply when button is pressed.
	case statePressed
	/// IBStyleProperty.List to only apply when button is disabled.
	case stateDisabled
	/// IBStyleProperty.List to only apply when button is selected.
	case stateSelected
	/// IBTextAlignment
	case textAlign
	/// UIColor
	case textColor

	/// A custom string property - more risky than other options, but provides unlimited functionality.
	case custom(String)

	/// All the options, in order of precedent.
	static var orderedList: [IBStyleProperty: Int] = [
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

	/// Sort a list of properties by order of precedent.
	public static func sort(_ first: IBStyleProperty, _ second: IBStyleProperty) -> Bool {
		return first.sortIndex < second.sortIndex
	}
	/// Order of precedent.
	public var sortIndex: Int {
		return IBStyleProperty.orderedList[self] ?? 100
	}
}

// MARK: IBStyles.Property Extensions
extension IBStyleProperty: Hashable {
    public var hashValue: Int {
        switch self {
			case (.custom(let v1)):
				return v1.hashValue
			default:
				return "\(self)".hashValue
        }
    }
}

// MARK: Property Equatable Protocol
extension IBStyleProperty: Equatable {}
public func == (lhs: IBStyleProperty, rhs: IBStyleProperty) -> Bool {
    switch (lhs, rhs) {
		case (.custom(let value1), .custom(let value2)):
			return value1 == value2
		default:
			return "\(lhs)" == "\(rhs)"
    }
}
