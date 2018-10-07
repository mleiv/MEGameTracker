//
//  IBStyler.swift
//
//  Created by Emily Ivie on 9/18/16.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

/// Applies IBStyles to IBStylable elements. It does not auto-detect when and how to do this,
///       alas, so each IBStylable element has to call home to it in order to trigger events.
///    Call applyStyles() inside IBStylable's prepareForInterfaceBuilder() or layoutSubviews().
public class IBStyler: NSObject {

    /// The stylable UIView in question.
    var styledElement: IBStylable?

    /// Tracks if styles have been applied once already.
    var didApplyStyles = false

    /// Checks if orientation has changed, because we may need to redraw.
    var lastContentSizeCategory: UIContentSizeCategory?

    /// Initialization. Start listening for window orientation changes.
    public init?(element: IBStylable?) {
        guard let element = element else { return nil }
        self.styledElement = element
        // BTW, delegate's identifier is not usually available at the time a delegate's init() is called. Sorry.
        super.init()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: nil,
            using: { [weak self] _ in self?.changeTextSize() })
    }

    /// Stop listening for window orientation changes.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Returns the stylesheet id for the UIView.
    var elementIdentifier: String {
        if let styledElementIdentifier = styledElement?.identifier,
            !styledElementIdentifier.isEmpty {
            return styledElementIdentifier
        }
        return styledElement?.defaultIdentifier ?? ""
    }

    /// Only applies IBStyles once.
    /// Apply layout stuff separately in subclassed layout subviews (sorry, no better way yet).
    public func applyStyles() -> Bool {
        guard IBStyleManager.current.stylesheet?.isInitialized == true
            && !elementIdentifier.isEmpty
            && !didApplyStyles else { return false }
        IBStyleManager.current.apply(identifier: elementIdentifier, to: styledElement as? UIView)
        styledElement?.applyStyles()
        didApplyStyles = true
        styledElement?.setNeedsLayout()
        styledElement?.layoutIfNeeded()
        return true
    }

    /// A special function for IBStyledButton elements to change state-specific styles on state-changing events
    ///    (see IBStyledButton for more).
    public func applyState(_ state: UIControl.State) {
        //changes only styles specific to a state, also ignores didApplyFormat flag
        guard !elementIdentifier.isEmpty  else { return }
        IBStyleManager.current.apply(identifier: elementIdentifier, to: styledElement as? UIView, forState: state)
        //styledElement?.setNeedsLayout()
        styledElement?.layoutIfNeeded()
    }

    /// For internal use only.
    /// Listens for user font size preference event, and accordingly changes font size for element.
    public func changeTextSize() {
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        if lastContentSizeCategory != contentSizeCategory {
            IBStyleManager.current.apply(identifier: elementIdentifier, to: styledElement as? UIView)
        }
        lastContentSizeCategory = contentSizeCategory
    }
}
