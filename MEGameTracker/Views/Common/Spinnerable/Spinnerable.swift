//
//  Spinnerable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/14/2016.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public protocol Spinnerable {
	func startSpinner(inView view: UIView?)
	func startSpinner(inView view: UIView?, title: String?)
	func updateSpinnerProgress(inView view: UIView?, percentCompleted: Int)
	func stopSpinner(inView view: UIView?)
	func stopSpinner(inView view: UIView?, isRemoveFromView: Bool)
	func isSpinning(inView view: UIView?) -> Bool
}

extension Spinnerable {
	public func startSpinner(inView view: UIView?) {
		startSpinner(inView: view, title: nil)
	}

	public func startSpinner(inView view: UIView?, title: String?) {
		guard !UIWindow.isInterfaceBuilder else { return }
		let useView = self is UITableViewController ? view?.superview : view
		guard let view = useView,
			  let spinner: SpinnerNib = {
			if let spinner = view.subviews.flatMap({ $0 as? SpinnerNib }).first {
				return spinner
			} else {
				if let spinner = SpinnerNib.loadNib(title: title) {
					view.addSubview(spinner)
					spinner.fillView(view)
					return spinner
				}
			}
			return nil
		}() else { return }
		spinner.start()
	}

	public func updateSpinnerProgress(inView view: UIView?, percentCompleted: Int) {
		guard !UIWindow.isInterfaceBuilder else { return }
		let useView = self is UITableViewController ? view?.superview : view
		if let spinner = useView?.subviews.flatMap({ $0 as? SpinnerNib }).first {
			spinner.updateProgress(percentCompleted: percentCompleted)
		}
	}

	public func stopSpinner(inView view: UIView?) {
		stopSpinner(inView: view, isRemoveFromView: false)
	}

	/// Some pages throw errors if the spinner remains (tableviews), so allow it to be removed.
	public func stopSpinner(inView view: UIView?, isRemoveFromView: Bool) {
		guard !UIWindow.isInterfaceBuilder else { return }
		let useView = self is UITableViewController ? view?.superview : view
		if let spinner = useView?.subviews.flatMap({ $0 as? SpinnerNib }).first {
			spinner.stop()
			if isRemoveFromView {
				spinner.removeFromSuperview()
			}
		}
	}

	public func isSpinning(inView view: UIView?) -> Bool {
		guard !UIWindow.isInterfaceBuilder else { return false }
		let useView = self is UITableViewController ? view?.superview : view
		return useView?.subviews.flatMap({ $0 as? SpinnerNib }).first != nil
	}
}
