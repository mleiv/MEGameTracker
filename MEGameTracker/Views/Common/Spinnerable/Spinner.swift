//
//  Spinner.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

struct Spinner {

	fileprivate var nib: SpinnerNib?

	/// - Parameter title: The message for the spinner
	/// - Parameter isShowProgress: Whether it should also display a progress bar
	///
	/// ## Usage Examples: ##
	/// ````
	/// let spinner = Spinner(title: "Test")
	/// spinner.show(from: myView, animated: true) {}
	/// spinner.dismiss(animated: true) {}
	/// ````
	public init(title: String?, isShowProgress: Bool = false) {
		nib = SpinnerNib.loadNib(title: title)
		nib?.isShowProgress = isShowProgress
	}

	/// Hides the currently displayed spinner.
	public func dismiss(animated: Bool, completion: (() -> Void)?) {
		let nib = self.nib
		UIView.animate(withDuration: 1.0, animations: {
			nib?.isHidden = true
		}) {  _ in
			nib?.removeFromSuperview()
			completion?()
		}
	}

	/// Displays a spinner in the center of specified view, with grayed out/disabled background.
	///
	/// Called when you know the UIView to insert into. Otherwise, use presentFromAppropriateController below.
	///
	/// ## Usage Examples: ##
	/// ````
	/// let spinner = Spinner(title: "Test")
	/// spinner.show(from: myView, animated: true) {}
	/// ````
	public func show(from parentView: UIView, animated: Bool, completion: (() -> Void)?) {
		if let nib = nib {
			if nib.superview == nil {
				parentView.addSubview(nib)
				nib.fillView(parentView)
			}

//			nib.isHidden = true
			parentView.layoutIfNeeded()
			nib.startSpinning()
			UIView.animate(withDuration: 1.0, animations: {
				nib.isHidden = false
			}) { _ in
				completion?()
			}
		}
	}

	public func updateProgress(percentCompleted: Int) {
		nib?.updateProgress(percentCompleted: percentCompleted)
	}

	public func changeIsShowProgress(_ isShowProgress: Bool) {
		nib?.isShowProgress = false
	}

	public func changeMessage(_ title: String) {
		nib?.title = title
	}

//	/// Displays a spinner in the center of specified view, with grayed out/disabled background.
//	///
//	/// (Based on: http://stackoverflow.com/a/29822896/5244752)
//	///
//	/// ## Usage Examples: ##
//	/// ````
//	/// let spinner = Spinner(title: "Test")
//	/// spinner.presentFromAppropriateController(animated: true) {}

//	/// ````
//	public func presentFromAppropriateController(animated: Bool, completion: (() -> Void)?) {
//		if let root = UIApplication.shared.keyWindow?.rootViewController {
//			present(from: root, animated: animated, completion: completion)
//		}

//	}

//
//	/// Finds the root view controller (excluding navigation and tab controllers) and presents alert from there.
//	private func present(from controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
//		if  let navigation = controller as? UINavigationController,
//			let visible = navigation.visibleViewController {
//				present(from: visible, animated: animated, completion: completion)
//		} else {
//			if  let tab = controller as? UITabBarController,
//				let selected = tab.selectedViewController {
//				present(from: selected, animated: animated, completion: completion)
//			} else {
//				show(from: controller.view, animated: animated, completion: completion)
//			}

//		}

//	}
}
