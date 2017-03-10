//
//  UIViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

extension UIViewController {
	var activeViewController: UIViewController? {
		if let tabController = self as? UITabBarController,
			let nextController = tabController.selectedViewController {
			return nextController.activeViewController
		} else if let navController = self as? UINavigationController,
			let nextController = navController.visibleViewController {
			return nextController.activeViewController
		} else if let nextController = self.presentedViewController {
			return nextController.activeViewController
		}
		return self
	}
	/**
		Locates the top-most view controller
	*/
	var topViewController: UIViewController? {
		return self.parent?.topViewController ?? self
	}
}
