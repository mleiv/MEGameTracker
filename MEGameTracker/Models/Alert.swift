//
//  Alert.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 4/14/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

/// Helper for showing alerts.
public struct Alert {

// MARK: Types

	public typealias ActionButtonType = (title: String, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void))

// MARK: Properties

	public var title: String
	public var description: String
	public var actions: [ActionButtonType] = []

// MARK: Change Listeners And Change Status Flags

	public static var onSignal = Signal<(Alert)>()

// MARK: Initialization

	public init(title: String?, description: String) {
		self.title = title ?? ""
		self.description = description
	}
}

// MARK: Basic Actions
extension Alert {

	/// Pops up an alert in the specified controller.
	public func show(fromController controller: UIViewController, sender: UIView? = nil) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		if actions.isEmpty {
			alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in }))
		} else {
			for action in actions {
				alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
			}
		}
		alert.popoverPresentationController?.sourceView = sender ?? controller.view
		alert.modalPresentationStyle = .popover

		// Alert default button defaults to window tintColor (red), 
		// Which is too similar to destructive button (red),
		// And I can't change it in Styles using appearance(),
		// So I have to do it here, which pisses me off. 
        alert.view.tintColor = UIColor.systemBlue // Styles.colors.altTint

		if let bounds = sender?.bounds {
			alert.popoverPresentationController?.sourceRect = bounds
		}
		controller.present(alert, animated: true, completion: nil)
	}
}
