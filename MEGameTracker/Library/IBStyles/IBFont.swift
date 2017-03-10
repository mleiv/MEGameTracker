//
//  IBFont.swift
//
//  Created by Emily Ivie on 9/17/16.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

/// Manages custom font settings.
/// Scales fonts based on user preferences.
public struct IBFont {

	public enum Size: Double {
		case smaller = 11.0, small = 13.0, normal = 15.0, big = 17.0, bigger = 19.0
	}

	public let size: CGFloat

	public enum Style {
		case normal, italic, medium, mediumItalic, semiBold, semiBoldItalic, bold, boldItalic
	}

	public let style: Style

	public init(style: Style, size: Size) {
		self.size = CGFloat(size.rawValue)
		self.style = style
	}
	public init(style: Style, size: CGFloat) {
		self.size = size
		self.style = style
	}

	/// Returns a proper UIFont based on the settings selected, and the user font scale preferences.
	/// - parameter isScalable:	  Whether or not to scale the font. Defaults to true.
	/// - parameter minFontSize:	 Minimum font size, defaults to 10.0.
	/// - returns: UIFont
	public func getUIFont(isScalable: Bool = true, minFontSize: CGFloat = 10.0) -> UIFont? {
		let name = IBStyles.fontsList[style]
		let size = isScalable ? selectedCategorySize(size: self.size, minFontSize: minFontSize) : self.size
		switch style {
			case .normal:
				return name != nil ? UIFont(name: name!, size: size) : .systemFont(ofSize: size)
			case .italic:
				return name != nil ? UIFont(name: name!, size: size) : .italicSystemFont(ofSize: size)
			case .medium:
				return name != nil ? UIFont(name: name!, size: size) : .systemFont(ofSize: size)
			case .mediumItalic:
				return name != nil ? UIFont(name: name!, size: size) : .italicSystemFont(ofSize: size)
			case .semiBold:
				return name != nil ? UIFont(name: name!, size: size) : .boldSystemFont(ofSize: size)
			case .semiBoldItalic:
				return name != nil ? UIFont(name: name!, size: size) : .italicSystemFont(ofSize: size)
			case .bold:
				return name != nil ? UIFont(name: name!, size: size) : .boldSystemFont(ofSize: size)
			case .boldItalic:
				return name != nil ? UIFont(name: name!, size: size) : .italicSystemFont(ofSize: size)
		}
	}

	/// Takes a font and makes it bolder.
	public func bold() -> IBFont {
		switch style {
			case .normal:
				return IBFont(style: .medium, size: size)
			case .italic:
				return IBFont(style: .mediumItalic, size: size)
			case .medium:
				return IBFont(style: .semiBold, size: size)
			case .mediumItalic:
				return IBFont(style: .boldItalic, size: size)
			case .semiBold:
				return IBFont(style: .bold, size: size)
			case .semiBoldItalic:
				return IBFont(style: .boldItalic, size: size)
			case .bold:
				return IBFont(style: .bold, size: size)
			case .boldItalic:
				return IBFont(style: .boldItalic, size: size)
		}
	}

	/// Takes a font and makes it italic.
	public func italic() -> IBFont {
		switch style {
			case .normal: fallthrough
			case .italic:
				return IBFont(style: .italic, size: size)
			case .medium: fallthrough
			case .mediumItalic:
				return IBFont(style: .mediumItalic, size: size)
			case .semiBold: fallthrough
			case .semiBoldItalic:
				return IBFont(style: .semiBoldItalic, size: size)
			case .bold: fallthrough
			case .boldItalic:
				return IBFont(style: .boldItalic, size: size)
		}
	}

	/// Internal function to scale a given size to its equivalent size under the user's selected preferred font sizing.
	func selectedCategorySize(size: CGFloat, minFontSize: CGFloat) -> CGFloat {
		let preferredContentSize = UIWindow.isInterfaceBuilder
			? UIContentSizeCategory.large
			: UIApplication.shared.preferredContentSizeCategory
		let fontSize: CGFloat = {
			switch preferredContentSize {
				case UIContentSizeCategory.extraExtraExtraLarge: return size + 3.0
				case UIContentSizeCategory.extraExtraLarge: return size + 2.0
				case UIContentSizeCategory.extraLarge: return size + 1.0
				case UIContentSizeCategory.large: return size
				case UIContentSizeCategory.medium: return size - 1.0
				case UIContentSizeCategory.small: return size - 2.0
				case UIContentSizeCategory.extraSmall: return size - 3.0
				default: return size
			}
		}()
		return max(minFontSize, fontSize)
	}
}
