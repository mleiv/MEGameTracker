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
    @IBOutlet fileprivate weak var linkTitle: MarkupLabel?
    @IBOutlet fileprivate weak var linkUrl: IBStyledLabel?
    
// MARK: Properties
    fileprivate var parent: RelatedLinksView?
    internal fileprivate(set) var link: String?
    // Linkable
    public var linkOriginController: UIViewController?
    
// MARK: Change Listeners And Change Status Flags
    fileprivate var isDefined = false
    
// MARK: Lifecycle Events
    public override func layoutSubviews() {
        if !isDefined {
            clearRow() // hide default data
        }
        super.layoutSubviews()
    }
    
// MARK: Initialization
    public func define(link: String?, parent: RelatedLinksView? = nil) {
        isDefined = true
        self.link = link
        self.parent = parent
//        self.linkOriginController = parent?.viewController // fallthru to didSelect on row
        setup()
    }
    
// MARK: Populate Data
    fileprivate func setup() {
        guard linkTitle != nil else { return }
        let linkParts = parseDomainFromLink(link ?? "")
        linkTitle?.text = linkParts.domain
        linkTitle?.isHidden = linkParts.domain.isEmpty
        linkUrl?.text = linkParts.url
        
        layoutIfNeeded()
    }
    
    /// Resets all text in the cases where row UI loads before data/setup.
    /// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
    fileprivate func clearRow() {
        linkTitle?.text = ""
        linkUrl?.text = ""
    }
    
// MARK: Supporting Functions
    fileprivate func parseDomainFromLink(_ link: String) -> (domain: String, url: String) {
        if let url = URL(string: link) {
            return (domain: url.host?.capitalized ?? "", url: url.path)
        }
        return (domain: "", url: "")
    }

}

extension RelatedLinkRow: Linkable {
//    var linkOriginController: UIViewController?
}
