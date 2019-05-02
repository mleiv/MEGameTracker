//
//  IBStylable.swift
//
//  Created by Emily Ivie on 3/4/15.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

/// Protocol for stylable UIKit elements.
/// See IBStyledThings for examples.
public protocol IBStylable where Self: UIView { // Swift 4.2 do not remove class
    var styler: IBStyler? { get }
    var identifier: String? { get }
    var defaultIdentifier: String { get } // optional
    func applyStyles() // optional
    func changeContentSizeCategory() // optional
}

extension IBStylable {
    public var defaultIdentifier: String { return "" }
    public func applyStyles() {}
    public func changeContentSizeCategory() {}
}

