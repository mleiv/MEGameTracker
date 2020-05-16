//
//  SideEffectsView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final public class SideEffectsView: SimpleArrayDataRow {

	@IBInspectable public var text: String?
    private var dummySideEffects: [String] = ["This is a side effect in Game 3."]
	var sideEffects: [String] {
		return UIWindow.isInterfaceBuilder ? dummySideEffects : (controller?.sideEffects ?? inspectableData)
	}
	lazy var inspectableData: [String] = { return self.dataFromText() }()
	public var controller: SideEffectsable? {
		didSet {
			reloadData()
		}
	}
	let linkHandler = LinkHandler()

	override var cellNibs: [String] { return ["SideEffectRow"] }
	override var rowCount: Int { return sideEffects.count }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard sideEffects.indices.contains((indexPath as NSIndexPath).row) else { return }
		(cell as? SideEffectRow)?.define(sideEffect: sideEffects[(indexPath as NSIndexPath).row], parent: self)
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func setupTable() {
		tableView?.allowsSelection = false
		tableView?.backgroundView?.isHidden = true
		tableView?.backgroundColor = UIColor.clear
		tableView?.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 10))
	}

	private func dataFromText() -> [String] {
		if text?.isEmpty == false {
			if text?.range(of: "\u{2028}\u{2028}") != nil {
				return (text ?? "").components(separatedBy: "\u{2028}\u{2028}").map { String($0) }
			} else if text?.range(of: "\n\n") != nil {
				return (text ?? "").components(separatedBy: "\n\n").map { String($0) }
			} else {
				return [text ?? ""]
			}
		} else {
			return []
		}
	}
}
