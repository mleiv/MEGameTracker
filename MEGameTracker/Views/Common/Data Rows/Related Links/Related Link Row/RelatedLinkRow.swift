//
//  RelatedLinkRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/23/16.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class RelatedLinkRow: UITableViewCell {

// MARK: Types
// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var linkTitle: UILabel?
	@IBOutlet private weak var linkUrl: UILabel?

// MARK: Properties
	private var parent: RelatedLinksView?
	internal fileprivate(set) var link: String?
	// Linkable
	public var linkOriginController: UIViewController?

// MARK: Change Listeners And Change Status Flags
	private var isDefined = false

// MARK: Lifecycle Events
	public override func layoutSubviews() {
		if !isDefined {
			clearRow() // hide default data
		}
		super.layoutSubviews()
	}

// MARK: Initialization
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(link: String?, parent: RelatedLinksView? = nil) {
		isDefined = true
		self.link = link
		self.parent = parent
//		self.linkOriginController = parent?.viewController // fallthru to didSelect on row
		setup()
	}

// MARK: Populate Data
	private func setup() {
		guard linkTitle != nil else { return }
		let linkParts = parseDomainFromLink(link ?? "")
		linkTitle?.text = linkParts.domain
		linkTitle?.isHidden = linkParts.domain.isEmpty
		linkUrl?.text = linkParts.url
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		linkTitle?.text = ""
		linkUrl?.text = ""
	}

// MARK: Supporting Functions
	private func parseDomainFromLink(_ link: String) -> (domain: String, url: String) {
		if let url = URL(string: link) {
			return (domain: url.host?.capitalized ?? "", url: url.path)
		}
		return (domain: "", url: "")
	}

}

extension RelatedLinkRow: Linkable {
//	var linkOriginController: UIViewController?
}
