//
//  VoiceActorLinkView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/23/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public typealias VoiceActorType = (name: String, url: String)

final public class VoiceActorLinkView: SimpleArrayDataRow {

	private var dummyLinks: [VoiceActorType] = [(name: "Mark Meer", url: "https://duckduckgo.com")]
	public var links: [VoiceActorType] {
		if UIWindow.isInterfaceBuilder {
			return dummyLinks
		} else if let actor = controller?.voiceActorName {
            var allowedCharacters = NSMutableCharacterSet.alphanumerics
            allowedCharacters.insert(charactersIn: "-._~")
			let url = String(
                format: searchActorTemplate,
                actor.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? "unknown"
            )
			return [(name: actor, url: url)]
		}
		return []
	}
    public var controller: VoiceActorLinkable? {
        didSet {
            reloadData()
        }
    }

	let searchActorTemplate = "https://duckduckgo.com/?q=%%22Mass+Effect%%22+wikipedia+IMDB+%%22%@%%22"
	let linkHandler = LinkHandler()

	override var heading: String? { return "Voice Actor" }
	override var cellNibs: [String] { return ["VoiceActorLinkRow"] }
	override var rowCount: Int { return links.count }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard links.indices.contains((indexPath as NSIndexPath).row) else { return }
		(cell as? VoiceActorLinkRow)?.define(voiceActor: links[(indexPath as NSIndexPath).row], parent: self)
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard links.indices.contains((indexPath as NSIndexPath).row) else { return }
		let voiceActor = links[(indexPath as NSIndexPath).row]
		if let url = URL(string: voiceActor.url),
		   let source = sender as? Linkable {
			source.linkOriginController = viewController
			linkHandler.openURL(url, source: source)
		}
	}
}
