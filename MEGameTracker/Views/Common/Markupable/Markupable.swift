//
//  Markupable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/12/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// All functions and properties pre-defined except for unmarkedText: String? and didMarkup: Bool = false.
/// call markupText() in layoutSubviews before super.layoutSubviews().
public protocol Markupable: class {
	var isMarkupable: Bool { get }
	var unmarkedText: String? { get set }
	var useAttributedText: NSAttributedString? { get set }
	func markup()
	func markupText(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString
	func markupLinks(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString
}

public protocol TextRendering: UIView {
    var textRenderingTextColor: UIColor { get set }
    var textRenderingFont: UIFont { get set }
    var textRenderingAttributedText: NSAttributedString? { get set }
}
extension UILabel: TextRendering {
    public var textRenderingTextColor: UIColor { get { return textColor } set { textColor = newValue } }
    public var textRenderingFont: UIFont { get { return font } set { font = newValue } }
    public var textRenderingAttributedText: NSAttributedString? { get { return attributedText } set { attributedText = newValue } }
}
extension UITextView: TextRendering {
    public var textRenderingTextColor: UIColor { get { return textColor! } set { textColor = newValue } }
    public var textRenderingFont: UIFont { get { return font! } set { font = newValue } }
    public var textRenderingAttributedText: NSAttributedString? { get { return attributedText } set { attributedText = newValue } }
}

extension Markupable where Self: TextRendering {
	// don't bother with hassle of NSAttributedString if we don't need it
	public var isMarkupable: Bool {
		let patterns = "(\\[(?:[^\\]]+\\|)?[^\\]]+\\]|\\*[^\\*]+\\*|\\_[^\\_]+\\_)"
		// add more patterns? bold, italic, list, etc?
		if let regex = try? NSRegularExpression(pattern: patterns, options: []) {
			let match = regex.firstMatch(
				in: unmarkedText ?? "",
				options: [],
				range: NSMakeRange(0, unmarkedText?.count ?? 0)
			)
//			print("\(unmarkedText) \(match)")
			return match != nil // verified: nothing to parse
		}
		return unmarkedText?.isEmpty == false // err on side of parsing
	}

	public func markup() {
		let attributedText = NSMutableAttributedString(
            attributedString: NSAttributedString(string: unmarkedText ?? "", attributes: [
                .foregroundColor: self.textRenderingTextColor,
                .font: self.textRenderingFont
            ])
		)
		guard unmarkedText?.isEmpty == false && isMarkupable else {
			useAttributedText = attributedText.string.isEmpty ? nil : attributedText
			return
		}
		let markedText = markupText(attributedText)
		let linkedText = markupLinks(markedText)
		useAttributedText = linkedText
	}

	public func markupText(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString {
		if let regex = try? NSRegularExpression(
				pattern: "(?:\\*[^\\*]+\\*|\\_[^\\_]+\\_|[\\_\\*]{2}[^\\*\\_]+[\\_\\*]{2})",
				options: .caseInsensitive
			) {
			let sourceString = attributedText.string
			var offsetIndex = 0
			regex.enumerateMatches(
				in: sourceString,
				options: NSRegularExpression.MatchingOptions(rawValue: 0),
				range: NSMakeRange(0, sourceString.count),
				using: { (result, _, _) in
					//(NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
					if let match = result, match.numberOfRanges == 1 {
						var wholeMatchRange = match.range(at: 0)
						wholeMatchRange.location += offsetIndex
						var text = attributedText.attributedSubstring(from: wholeMatchRange)
						let textString = text.string
						if textString.length > 4
							&& (textString.stringFrom(0, to: 2) == "*_" || textString.stringFrom(0, to: 2) == "_*") {
                            let subtext = text.attributedSubstring(from: NSRange(location: 2, length: text.length - 4))
							text = shiftStyleToBoldItalic(text: subtext)
						} else if textString.length > 2 {
							if textString.first == "*" {
                                let subtext = text.attributedSubstring(from: NSRange(location: 1, length: text.length - 2))
								text = shiftStyleToBold(text: subtext)
							} else if textString.first == "_" {
                                let subtext = text.attributedSubstring(from: NSRange(location: 1, length: text.length - 2))
                                text = shiftStyleToItalic(text: subtext)
							}
						}
						offsetIndex -= wholeMatchRange.length - text.length
						attributedText.replaceCharacters(in: wholeMatchRange, with: text)
					}
				}
			)
		}
		return attributedText
	}

	public func markupLinks(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString {
		if let regex = try? NSRegularExpression(
				pattern: "\\[([^\\]]+\\|)?([^\\]]+)\\]",
				options: .caseInsensitive
			) {
			let sourceString = attributedText.string
			var offsetIndex = 0
			regex.enumerateMatches(
				in: sourceString,
				options: NSRegularExpression.MatchingOptions(rawValue: 0),
				range: NSMakeRange(0, sourceString.count),
				using: { (result, _, _) in
					//(NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
					if let match = result, match.numberOfRanges == 3 {
						var wholeMatchRange = match.range(at: 0)
						wholeMatchRange.location += offsetIndex
						var textRange = match.range(at: 1)
						// don't do offset yet, may be invalid match (length == 0)
						var linkRange = match.range(at: 2)
						linkRange.location += offsetIndex
						let link = attributedText.attributedSubstring(from: linkRange).string
						let text: NSAttributedString = {
							if textRange.length == 0 {
								// no name given, get one from object:
								let text = NSMutableAttributedString(string: self.parseLinkForObjectName(link) ?? "")
								text.addAttributes(attributedText.attributes(
									at: linkRange.location,
									effectiveRange: &linkRange),
									range: NSMakeRange(0, text.length)
								)
								return text
							} else {
								// use name provided:
								textRange.location += offsetIndex
								textRange.length -= 1 // remove bar divider
								return attributedText.attributedSubstring(from: textRange)
							}
						}()
						let newAttributedText = self is Linkable ? self.createLink(oldAttributedText: text, link: link) : text
						offsetIndex -= (wholeMatchRange.length - newAttributedText.length)
						attributedText.replaceCharacters(in: wholeMatchRange, with: newAttributedText)
					}
				}
			)
		}
		return attributedText
	}

	private func parseLinkForObjectName(_ urlString: String) -> String? {
		if let url = URL(string: urlString),
			let page = url.host,
			let id = url.queryDictionary["id"] {
			switch page {
			case "person": return Person.get(id: id)?.name
			case "item": return Item.get(id: id)?.name
			case "map": return Map.get(id: id)?.name
			case "maplocation":
				if let type = MapLocationType(stringValue: url.queryDictionary["type"]) {
					return MapLocation.get(id: id, type: type)?.name
				} else {
					return nil
				}
			case "mission": return Mission.get(id: id)?.name
			default: break
			}
		}
		return nil
	}

	private func createLink(oldAttributedText: NSAttributedString, link: String) -> NSAttributedString {
		let attributedText = NSMutableAttributedString(attributedString: oldAttributedText)
		let isInternalLink = NSPredicate(format:"SELF MATCHES %@", "megametracker:.*").evaluate(with: link)
		let hideIcon = NSPredicate(format:"SELF MATCHES %@", ".*\\&hideicon=1.*").evaluate(with: link)
		if !hideIcon,
			let image = UIImage(
				named: isInternalLink ? "Internal Link" : "Link",
				in: Bundle.currentAppBundle,
				compatibleWith: nil
			) {
			let linkImage = LineCenteredTextImage()
			linkImage.image = image
			let attributedLinkImage = NSAttributedString(attachment: linkImage)
			attributedText.replaceCharacters(in: NSMakeRange(0, 0), with: attributedLinkImage)
		}
		attributedText.addAttribute(
            .link,
			value: link,
			range: NSMakeRange(0, attributedText.length)
		)
		return attributedText
		// this changes the styles (color, font, etc), provided you have turned off default styling inside Styles.swift:
		// Styles.convertToStyleCategory(.Link, attributedText: attributedText)
	}
    
    private func shiftStyleToItalic(text: NSAttributedString) -> NSAttributedString {
        if let descriptor = textRenderingFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            let mutableText = NSMutableAttributedString(attributedString: text)
            mutableText.addAttribute(.font, value: UIFont(descriptor: descriptor, size: textRenderingFont.pointSize), range: NSRange(location: 0, length: text.length))
            return mutableText
        }
        return text
    }
    
    private func shiftStyleToBold(text: NSAttributedString) -> NSAttributedString {
        if let descriptor = textRenderingFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            let mutableText = NSMutableAttributedString(attributedString: text)
            mutableText.addAttribute(.font, value: UIFont(descriptor: descriptor, size: textRenderingFont.pointSize), range: NSRange(location: 0, length: text.length))
            return mutableText
        }
        return text
    }
    
    private func shiftStyleToBoldItalic(text: NSAttributedString) -> NSAttributedString {
        if let descriptor = textRenderingFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
            let mutableText = NSMutableAttributedString(attributedString: text)
            mutableText.addAttribute(.font, value: UIFont(descriptor: descriptor, size: textRenderingFont.pointSize), range: NSRange(location: 0, length: text.length))
            return mutableText
        }
        return text
    }
}
