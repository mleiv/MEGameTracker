//
//  UIAlertController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

extension UIAlertController {

	/// based on: http://stackoverflow.com/a/29822896/5244752
	///
	/// ## Usage Examples: ##
	/// ````
	/// let alertController = UIAlertController(title: "title", message: "message", preferredStyle: .Alert)
	/// alertController.presentFromAppropriateController(animated: true) {}
	/// ````
	public func presentFromAppropriateController(animated: Bool, completion: (() -> Void)?) {
		if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController  {
			present(from: root, animated: animated, completion: completion)
		}
	}

	/// Finds the root view controller (excluding navigation and tab controllers) and presents alert from there.
	private func present(from controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
		if  let navigation = controller as? UINavigationController,
			let visible = navigation.visibleViewController {
				present(from: visible, animated: animated, completion: completion)
		} else {
		  if  let tab = controller as? UITabBarController,
			  let selected = tab.selectedViewController {
				present(from: selected, animated: animated, completion: completion)
		  } else {
			  controller.present(self, animated: animated, completion: completion)
		  }
		}
	}
}
