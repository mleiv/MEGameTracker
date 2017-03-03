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
    func markupText()
    func markupLinks() -> Int
}

extension Markupable where Self: IBStylable, Self: UIView {
    
    // don't bother with hassle of NSAttributedString if we don't need it
    public var isMarkupable: Bool {
        let patterns = "(\\[(?:[^\\]]+\\|)?[^\\]]+\\]|\\*[^\\*]+\\*|\\_[^\\_]+\\_)"
        // add more patterns? bold, italic, list, etc?
        if let regex = try? NSRegularExpression(pattern: patterns, options: []) {
            let match = regex.firstMatch(in: unmarkedText ?? "", options: [], range: NSMakeRange(0, unmarkedText?.characters.count ?? 0))
//            print("\(unmarkedText) \(match)")
            return match != nil // verified: nothing to parse
        }
        return unmarkedText?.isEmpty == false // err on side of parsing
    }
    
    public func markupText() {
//        guard !UIWindow.isInterfaceBuilder else { return }
        useAttributedText = NSMutableAttributedString(attributedString: Styles.applyStyle(identifier ?? "", toString: unmarkedText ?? ""))
        guard isMarkupable else { return }
        if let regex = try? NSRegularExpression(pattern: "(?:\\*[^\\*]+\\*|\\_[^\\_]+\\_|[\\_\\*]{2}[^\\*\\_]+[\\_\\*]{2})", options: .caseInsensitive) {
            let attributedText = NSMutableAttributedString(attributedString: self.useAttributedText ?? NSAttributedString())
            let sourceString = attributedText.string
            var offsetIndex = 0
            regex.enumerateMatches(in: sourceString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, sourceString.characters.count), using: { (result, flags, _) in
            //(NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
                if let match = result , match.numberOfRanges == 1  {
                    var wholeMatchRange = match.rangeAt(0)
                    wholeMatchRange.location += offsetIndex
                    var text = attributedText.attributedSubstring(from: wholeMatchRange)
                    let textString = text.string
                    if textString.length > 4 && (textString.stringFrom(0, to: 2) == "*_" || textString.stringFrom(0, to: 2) == "_*"), let identifier = self.identifier {
                        text = Styles.shiftStyleToBoldItalic(identifier, text: textString.stringFrom(2, to: -2))
                    } else if textString.length > 2 {
                        if textString.characters.first == "*", let identifier = self.identifier {
                            text = Styles.shiftStyleToBold(identifier, text: textString.stringFrom(1, to: -1))
                        } else if textString.characters.first == "_", let identifier = self.identifier {
                            text = Styles.shiftStyleToItalic(identifier, text: textString.stringFrom(1, to: -1))
                        }
                    }
                    offsetIndex -= (wholeMatchRange.length - text.length)
                    attributedText.replaceCharacters(in: wholeMatchRange, with: text)
                }
            })
            self.useAttributedText = attributedText
        }
    }

    public func markupLinks() -> Int {
        var linksFound = 0
//        guard !UIWindow.isInterfaceBuilder else { return 0 }
        guard isMarkupable else { return 0 }
        if let regex = try? NSRegularExpression(pattern: "\\[([^\\]]+\\|)?([^\\]]+)\\]", options: .caseInsensitive) {
            let attributedText = NSMutableAttributedString(attributedString: self.useAttributedText ?? NSAttributedString())
            let sourceString = attributedText.string
            var offsetIndex = 0
            regex.enumerateMatches(in: sourceString, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, sourceString.characters.count), using: { (result, flags, _) in
            //(NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void)
                if let match = result , match.numberOfRanges == 3  {
                    linksFound += 1
                    var wholeMatchRange = match.rangeAt(0)
                    wholeMatchRange.location += offsetIndex
                    var textRange = match.rangeAt(1)
                    // don't do offset yet, may be invalid match (length == 0)
                    var linkRange = match.rangeAt(2)
                    linkRange.location += offsetIndex
                    let link = attributedText.attributedSubstring(from: linkRange).string
                    let text: NSAttributedString = {
                        if textRange.length == 0 {
                            // no name given, get one from object:
                            let text = NSMutableAttributedString(string: self.parseLinkForObjectName(link) ?? "")
                            text.addAttributes(attributedText.attributes(at: linkRange.location, effectiveRange: &linkRange), range: NSMakeRange(0, text.length))
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
            })
            self.useAttributedText = attributedText
        }
        return linksFound
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
    
    public func createLink(oldAttributedText: NSAttributedString, link: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(attributedString: oldAttributedText)
        let isInternalLink = NSPredicate(format:"SELF MATCHES %@", "megametracker:.*").evaluate(with: link)
        let hideIcon = NSPredicate(format:"SELF MATCHES %@", ".*\\&hideicon=1.*").evaluate(with: link)
        if !hideIcon, let image = UIImage(named: isInternalLink ? "Internal Link" : "Link", in: Bundle.currentAppBundle, compatibleWith: nil) {
            let linkImage = LineCenteredTextImage()
            linkImage.image = image
            let attributedLinkImage = NSAttributedString(attachment: linkImage)
            attributedText.replaceCharacters(in: NSMakeRange(0, 0), with: attributedLinkImage)
        }
        attributedText.addAttribute(NSLinkAttributeName, value: link, range: NSMakeRange(0, attributedText.length))
        return attributedText
        // this changes the styles (color, font, etc), provided you have turned off default styling inside Styles.swift:
        // Styles.convertToStyleCategory(.Link, attributedText: attributedText)
    }
    
}

