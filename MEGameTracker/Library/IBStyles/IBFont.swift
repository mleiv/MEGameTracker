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

    //title1
    //title2
    //title3
    //headline
    //body
    //callout
    //subhead
    //footnote
    //caption1
    //caption2

    public enum Style {
        case normal, italic, medium, mediumItalic, semiBold, semiBoldItalic, bold, boldItalic
    }
    public enum Size: Double {
        case smaller = 11.0, small = 13.0, normal = 15.0, big = 17.0, bigger = 19.0
    }

    public let style: Style
    public let size: Size

    public func getUIFont() -> UIFont? {
        guard let name = IBStyleManager.current.stylesheet?.fonts[style],
            let font = UIFont(name: name, size: CGFloat(size.rawValue))
            else { return nil }
        if #available(iOS 11.0, *) {
            switch size {
            case .smaller: return UIFontMetrics(forTextStyle: .caption1).scaledFont(for: font)
            case .small: return UIFontMetrics(forTextStyle: .footnote).scaledFont(for: font)
            case .normal: return UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
            case .big: return UIFontMetrics(forTextStyle: .title3).scaledFont(for: font)
            case .bigger: return UIFontMetrics(forTextStyle: .title1).scaledFont(for: font)
            }
        } else {
            // Fallback on earlier versions
            return font
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
}
