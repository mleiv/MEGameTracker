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
	var identifier: String? { get }
	var isMarkupable: Bool { get }
	var unmarkedText: String? { get set }
	var useAttributedText: NSAttributedString? { get set }
	func markup()
	func markupText(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString
	func markupLinks(_ attributedText: NSMutableAttributedString) -> NSMutableAttributedString
}

extension Markupable where Self: UIView {

	// don't bother with hassle of NSAttributedString if we don't need it
	public var isMarkupable: Bool {
		let patterns = "(\\[(?:[^\\]]+\\|)?[^\\]]+\\]|\\*[^\\*]+\\*|\\_[^\\_]+\\_)"
		// add more patterns? bold, italic, list, etc?
		if let regex = try? NSRegularExpression(pattern: patterns, options: []) {
			let match = regex.firstMatch(
				in: unmarkedText ?? "",
				options: [],
				range: NSMakeRange(0, unmarkedText?.characters.count ?? 0)
			)
//			print("\(unmarkedText) \(match)")
			return match != nil // verified: nothing to parse
		}
		return unmarkedText?.isEmpty == false // err on side of parsing
	}

	public func markup() {
		let attributedText = NSMutableAttributedString(
			attributedString: Styles.current.applyStyle(identifier ?? "", toString: unmarkedText ?? "")
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
				range: NSMakeRange(0, sourceString.characters.count),
				using: { (result, _, _) in
					//(NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
					if let match = result, match.numberOfRanges == 1 {
						var wholeMatchRange = match.range(at: 0)
						wholeMatchRange.location += offsetIndex
						var text = attributedText.attributedSubstring(from: wholeMatchRange)
						let textString = text.string
						if textString.length > 4
							&& (textString.stringFrom(0, to: 2) == "*_" || textString.stringFrom(0, to: 2) == "_*"),
							let identifier = self.identifier {
							text = Styles.current.shiftStyleToBoldItalic(identifier, text: textString.stringFrom(2, to: -2))
						} else if textString.length > 2 {
							if textString.characters.first == "*", let identifier = self.identifier {
								text = Styles.current.shiftStyleToBold(identifier, text: textString.stringFrom(1, to: -1))
							} else if textString.characters.first == "_", let identifier = self.identifier {
								text = Styles.current.shiftStyleToItalic(identifier, text: textString.stringFrom(1, to: -1))
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
				range: NSMakeRange(0, sourceString.characters.count),
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

	fileprivate func parseLinkForObjectName(_ urlString: String) -> String? {
		if let url = URL(string: urlString),
			let page = url.host,
			let id = url.queryDictionary["id"] {
			switch page {
			case "person": return Person.get(id: id)?.name
			case "item": return Item.get(id: id)?.name
			case "map": return Map.get(id: id)?.name
			case "maplocation":
				if let type = MapLocationType(stringValue: url.queryDictionary["type"] ?? "") {
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

	fileprivate func createLink(oldAttributedText: NSAttributedString, link: String) -> NSAttributedString {
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
		attributedText.addAttribute(NSAttributedStringKey.link,
			value: link,
			range: NSMakeRange(0, attributedText.length)
		)
		return attributedText
		// this changes the styles (color, font, etc), provided you have turned off default styling inside Styles.swift:
		// Styles.convertToStyleCategory(.Link, attributedText: attributedText)
	}
}
