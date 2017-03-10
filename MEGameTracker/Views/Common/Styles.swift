//
//  Styles.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/11/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

extension Styles {
	public struct Colors {
		public static let normalColor = UIColor.black
		public static let normalOppositeColor = UIColor.white
		public static let tintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
		public static let renegadeColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
		public static let tintOppositeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		public static let accentColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
		public static let accentOppositeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		public static let altAccentColor = UIColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1.0)
		public static let paragonColor = UIColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1.0)
		public static let paragadeColor = UIColor(red: 0.7, green: 0.3, blue: 0.7, alpha: 1.0)
		public static let navBarTitle = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
		public static let borderColor = UIColor.black
		public static let backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
		public static let overlayColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
		public static let rowHighlightColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
		public static let disabledColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
		public static let disabledOppositeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		public static let linkOnWhiteColor = UIColor(red: 0.2, green: 0.3, blue: 0.9, alpha: 1.0)
		public static let linkOnBlackColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
	}
	/// Define your fonts using general style groups.
	/// Fonts are automatically scalable (property .hasAdjustableFontSize can remove this behavior).
	public struct Fonts {
		// swiftlint:disable type_name
		public struct body {
			public static let normalStyle = IBFont(style: .normal, size: .normal)
			public static let boldStyle = IBFont(style: .medium, size: .normal)
			public static let italicStyle = IBFont(style: .italic, size: .normal)
			public static let boldItalicStyle = IBFont(style: .mediumItalic, size: .normal)
		}
		public struct title {
			public static let normalStyle = IBFont(style: .normal, size: .bigger)
			public static let boldStyle = IBFont(style: .medium, size: .bigger)
		}
		public struct header {
			public static let normalStyle = IBFont(style: .normal, size: .big)
			public static let boldStyle = IBFont(style: .medium, size: .big)
		}
		public struct caption {
			public static let normalStyle = IBFont(style: .normal, size: .small)
			public static let boldStyle = IBFont(style: .medium, size: .small)
			public static let italicStyle = IBFont(style: .italic, size: .small)
			public static let boldItalicStyle = IBFont(style: .mediumItalic, size: .small)
		}
		public struct tiny {
			public static let normalStyle = IBFont(style: .normal, size: .smaller)
			public static let boldStyle = IBFont(style: .medium, size: .smaller)
			public static let italicStyle = IBFont(style: .italic, size: .smaller)
		}
		// swiftlint:enable type_name
	}

	public static var fontsList: [IBFont.Style: String] {
		return [
			.normal: "Avenir-Roman", // also -Book?
			.italic: "Avenir-Oblique",
			.medium: "Avenir-Medium",
			.mediumItalic: "Avenir-MediumOblique",
			.semiBold: "Avenir-Heavy",
			.semiBoldItalic: "Avenir-HeavyOblique",
			.bold: "Avenir-Black",
			.boldItalic: "Avenir-BlackOblique",
		]
	}

	public static var stylesList: [String: IBStyles.Properties] {
		return [
			"NormalFilledBox": [
				.backgroundColor: Colors.normalColor,
			],
			"TintFilledBox": [
				.backgroundColor: Colors.tintColor,
			],
			"TintBorderBox": [
				.borderColor: Colors.tintColor,
				.borderWidth: 2.0,
			],
			"Caption.NormalColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.normalColor,
			],
			"Caption.NormalColor.Italic": [
				.font: Fonts.caption.italicStyle,
				.textColor: Colors.normalColor,
			],
			"Caption.NormalColor.Medium": [
				.font: Fonts.caption.boldStyle,
				.textColor: Colors.normalColor,
			],
			"Body.NormalColor": [
				.font: Fonts.body.normalStyle,
				.textColor: Colors.normalColor,
			],
			"Body.NormalColor.Italic": [
				.font: Fonts.body.italicStyle,
				.textColor: Colors.normalColor,
			],
			"Body.NormalColor.Medium": [
				.font: Fonts.body.boldStyle,
				.textColor: Colors.normalColor,
			],
			"Body.NormalColor.MediumItalic": [
				.font: Fonts.body.boldItalicStyle,
				.textColor: Colors.normalColor,
			],
			"Header.NormalColor": [
				.font: Fonts.header.normalStyle,
				.textColor: Colors.normalColor,
			],
			"Header.NormalColor.Medium": [
				.font: Fonts.header.boldStyle,
				.textColor: Colors.normalColor,
			],
			"Title.NormalColor.Medium": [
				.font: Fonts.title.boldStyle,
				.textColor: Colors.normalColor,
			],
			"Caption.TintColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.tintColor,
			],
			"Caption.TintColor.Italic": [
				.font: Fonts.caption.italicStyle,
				.textColor: Colors.tintColor,
			],
			"Caption.TintColor.Medium": [
				.font: Fonts.caption.boldStyle,
				.textColor: Colors.tintColor,
			],
			"Body.TintColor": [
				.font: Fonts.body.normalStyle,
				.textColor: Colors.tintColor,
			],
			"Body.TintColor.Medium": [
				.font: Fonts.body.boldStyle,
				.textColor: Colors.tintColor,
			],
			"Header.TintColor": [
				.font: Fonts.header.normalStyle,
				.textColor: Colors.tintColor,
			],
			"Caption.RenegadeColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.renegadeColor,
			],
			"Caption.ParagonColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.paragonColor,
			],
			"Caption.ParagadeColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.paragadeColor,
			],
			"Caption.AccentColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.accentColor,
			],
			"Caption.AccentColor.Italic": [
				.font: Fonts.caption.italicStyle,
				.textColor: Colors.accentColor,
			],
			"Body.AccentColor": [
				.font: Fonts.body.normalStyle,
				.textColor: Colors.accentColor,
			],
			"Body.AccentColor.Italic": [
				.font: Fonts.body.italicStyle,
				.textColor: Colors.accentColor,
			],
			"Header.AccentColor": [
				.font: Fonts.header.normalStyle,
				.textColor: Colors.accentColor,
			],
			"Caption.AltAccentColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.altAccentColor,
			],
			"Caption.AltAccentColor.Italic": [
				.font: Fonts.caption.italicStyle,
				.textColor: Colors.altAccentColor,
			],
			"Caption.AltAccentColor.Medium": [
				.font: Fonts.caption.boldStyle,
				.textColor: Colors.altAccentColor,
			],
			"Body.AltAccentColor": [
				.font: Fonts.body.normalStyle,
				.textColor: Colors.altAccentColor,
			],
			"Caption.TintOppositeColor.Medium": [
				.font: Fonts.caption.boldStyle,
				.textColor: Colors.tintOppositeColor,
			],
			"Caption.DisabledColor": [
				.font: Fonts.caption.normalStyle,
				.textColor: Colors.disabledColor,
			],
			"Caption.DisabledColor.Italic": [
				.font: Fonts.caption.italicStyle,
				.textColor: Colors.disabledColor,
			],
			"Body.DisabledColor.Italic": [
				.font: Fonts.body.italicStyle,
				.textColor: Colors.disabledColor,
			],
			"Caption.DisabledOppositeColor.MediumItalic": [
				.font: Fonts.caption.boldItalicStyle,
				.textColor: Colors.disabledOppositeColor,
			],
			"Box.FauxSegmentedControl": [
				.backgroundColor: Colors.accentOppositeColor,
				.borderColor: Colors.accentColor,
				.cornerRadius: 5.0,
				.borderWidth: 1.0,
			],
			"TextField": [
				.font: Fonts.body.normalStyle,
				.textColor: Colors.normalColor,
				.cornerRadius: 5.0,
				.borderWidth: 1.0,
				.borderColor: Colors.accentColor,
				.backgroundColor: Colors.backgroundColor,
				.padding: [0.0, 10.0],
			],
		]
	}

	/// Applies styles to a string and returns NSAttributedString.
	/// Doesn't recognize .Inherit (sorry)
	public static func applyStyle(_ style: String, toString text: String) -> NSAttributedString {
		let attributes = getAttributesByStyleName(style)
		return NSAttributedString(string: text, attributes: attributes)
	}

	public static func applyStyle(
		_ style: String,
		toString text: String,
		inAttributedString attributedText: NSMutableAttributedString
	) -> NSAttributedString {
		let haystack = NSString(string: attributedText.string)
		attributedText.setAttributes(getAttributesByStyleName(style), range: haystack.range(of: text))
		return attributedText
	}

	public static func shiftStyleToItalic(_ style: String, text: String) -> NSAttributedString {
		if let styles = Styles.stylesList[style] {
			var attributes: [String: AnyObject] = [:]
			if let fontStyle = styles[.font] as? IBFont {
				attributes[NSFontAttributeName] = fontStyle.italic().getUIFont()
			}
			if let color = styles[.textColor] as? UIColor {
				attributes[NSForegroundColorAttributeName] = color
			}
			attributes["identifier"] = style as AnyObject?
			return NSAttributedString(string: text, attributes: attributes)
		}
		return NSAttributedString()
	}

	public static func shiftStyleToBold(_ style: String, text: String) -> NSAttributedString {
		if let styles = Styles.stylesList[style] {
			var attributes: [String: AnyObject] = [:]
			if let fontStyle = styles[.font] as? IBFont {
				attributes[NSFontAttributeName] = fontStyle.bold().getUIFont()
			}
			if let color = styles[.textColor] as? UIColor {
				attributes[NSForegroundColorAttributeName] = color
			}
			attributes["identifier"] = style as AnyObject?
			return NSAttributedString(string: text, attributes: attributes)
		}
		return NSAttributedString()
	}

	public static func shiftStyleToBoldItalic(_ style: String, text: String) -> NSAttributedString {
		if let styles = Styles.stylesList[style] {
			var attributes: [String: AnyObject] = [:]
			if let fontStyle = styles[.font] as? IBFont {
				attributes[NSFontAttributeName] = fontStyle.italic().bold().getUIFont()
			}
			if let color = styles[.textColor] as? UIColor {
				attributes[NSForegroundColorAttributeName] = color
			}
			attributes["identifier"] = style as AnyObject?
			return NSAttributedString(string: text, attributes: attributes)
		}
		return NSAttributedString()
	}

	public static func applyStyle(
		_ style: String,
		toAttributedText attributedText: NSMutableAttributedString
	) -> NSAttributedString {
		let attributes = getAttributesByStyleName(style)
		attributedText.addAttributes(attributes, range: NSMakeRange(0, attributedText.length))
		return attributedText
	}

	fileprivate static func getAttributesByStyleName(_ style: String) -> [String: AnyObject] {
		if let styles = Styles.stylesList[style] {
			var attributes: [String: AnyObject] = [:]
			if let fontStyle = styles[.font] as? IBFont {
				attributes[NSFontAttributeName] = fontStyle.getUIFont()
			}
			if let color = styles[.textColor] as? UIColor {
				attributes[NSForegroundColorAttributeName] = color
			}
			attributes["identifier"] = style as AnyObject?
			return attributes
		}
		return [:]
	}

	fileprivate static func convertStyleCategory(_ newStyleCategory: StyleCategory, oldStyle: String) -> String {
		switch newStyleCategory {
			case .link:
				if let regex = try? NSRegularExpression(pattern: "^[^\\.]+", options: .caseInsensitive) {
					return regex.stringByReplacingMatches(
						in: oldStyle,
						options: NSRegularExpression.MatchingOptions(rawValue: 0),
						range: NSMakeRange(0, oldStyle.characters.count),
						withTemplate: "AltAccentColor"
					)
				}
			default: break
		}
		return oldStyle
	}

	public static func convertToStyleCategory(
		_ newStyleCategory: StyleCategory,
		attributedText: NSAttributedString
	) -> NSAttributedString {
		var newAttributedText = NSMutableAttributedString(attributedString: attributedText)
		attributedText.enumerateAttribute(
			"identifier",
			in: NSMakeRange(0, attributedText.length),
			options: NSAttributedString.EnumerationOptions(rawValue: 0)
		) { (value, _, _) -> Void in
			if let oldValue = value as? String {
				let newStyle = convertStyleCategory(newStyleCategory, oldStyle: oldValue)
				newAttributedText = NSMutableAttributedString(
					attributedString: self.applyStyle(newStyle, toAttributedText: newAttributedText)
				)
			}
		}
		return newAttributedText
	}

	public enum StyleCategory {
		case plain, italic, medium, link
	}

	public static func applyGlobalStyles(_ window: UIWindow?) {
		window?.tintColor = Colors.tintColor

		if let titleFont = Fonts.body.boldStyle.getUIFont() {
			UINavigationBar.appearance().titleTextAttributes = [
				NSFontAttributeName: titleFont,
				NSForegroundColorAttributeName: Colors.navBarTitle,
			]
		}
		if let titleFont = Fonts.body.normalStyle.getUIFont() {
			UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: titleFont], for: UIControlState())
		}

		UISegmentedControl.appearance().tintColor = Colors.tintColor
		UISegmentedControl.appearance().backgroundColor = Colors.tintOppositeColor
		UISegmentedControl.appearance().setTitleTextAttributes([
			NSForegroundColorAttributeName: Colors.tintOppositeColor
		], for: .disabled)
		UISwitch.appearance().onTintColor = Styles.Colors.tintColor
		UISwitch.appearance().tintColor = Styles.Colors.tintOppositeColor

		if let fontNormal = Fonts.body.normalStyle.getUIFont() {
			UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: fontNormal], for: .normal)
		}

		let bundle = Bundle.currentAppBundle
		let minimumTrackImage = UIImage(named: "Slider Filled", in: bundle, compatibleWith: nil)?
									.resizableImage(withCapInsets: UIEdgeInsetsMake(0,5,0,5))
		let maximumTrackImage = UIImage(named: "Slider Empty", in: bundle, compatibleWith: nil)?
									.resizableImage(withCapInsets: UIEdgeInsetsMake(0,5,0,5))
		let thumbImage = UIImage(named: "Slider Thumb", in: bundle, compatibleWith: nil)
		UISlider.appearance().setMinimumTrackImage(minimumTrackImage, for: UIControlState())
		UISlider.appearance().setMaximumTrackImage(maximumTrackImage, for: UIControlState())
		UISlider.appearance().setThumbImage(thumbImage, for: UIControlState())
		UISlider.appearance().setThumbImage(thumbImage, for: .highlighted)

		UITextView.appearance().linkTextAttributes = [
			NSForegroundColorAttributeName: Colors.linkOnWhiteColor
		]

		let toolbarItems = UIBarButtonItem.appearance()
		toolbarItems.tintColor = Colors.tintColor
		if let font = Fonts.caption.boldStyle.getUIFont() {
			toolbarItems.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
		}
	}
}
