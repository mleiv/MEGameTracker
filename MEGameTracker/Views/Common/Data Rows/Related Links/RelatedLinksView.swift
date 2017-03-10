//
//  RelatedLinksView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/23/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final public class RelatedLinksView: SimpleArrayDataRow {

	@IBInspectable public var text: String?

	public var links: [String] {
		if UIWindow.isInterfaceBuilder {
			return ["https://masseffect.wikia.com/wiki/Sahrabarik"]
		}
		return controller?.relatedLinks ?? inspectableData
	}

	lazy var inspectableData: [String] = { return self.dataFromText() }()

	public var controller: RelatedLinksable? {
		didSet {
			reloadData()
		}
	}

	let linkHandler = LinkHandler()

	override var heading: String? { return "Additional Information Online" }
	override var cellNibs: [String] { return ["RelatedLinkRow"] }
	override var rowCount: Int { return links.count }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard links.indices.contains((indexPath as NSIndexPath).row) else { return }
		(cell as? RelatedLinkRow)?.define(link: links[(indexPath as NSIndexPath).row], parent: self)
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard links.indices.contains((indexPath as NSIndexPath).row) else { return }
		let link = links[(indexPath as NSIndexPath).row]
		if let url = URL(string: link),
		   let source = sender as? Linkable {
			source.linkOriginController = viewController
			linkHandler.openURL(url, source: source)
		}
	}

	fileprivate func dataFromText() -> [String] {
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
