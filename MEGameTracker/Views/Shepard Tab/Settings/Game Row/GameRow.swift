//
//  GameRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/12/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class GameRow: UITableViewCell {

// MARK: Types
// MARK: Constants
	fileprivate let dateMessage = "Last Played: %@"

// MARK: Outlets
	@IBOutlet fileprivate weak var photoImageView: UIImageView?
	@IBOutlet fileprivate weak var nameLabel: UILabel?
	@IBOutlet fileprivate weak var titleLabel: UILabel?
	@IBOutlet fileprivate weak var dateLabel: UILabel?

// MARK: Properties
	internal fileprivate(set) var shepard: Shepard?

// MARK: Change Listeners And Change Status Flags
	fileprivate var isDefined = false

// MARK: Lifecycle Events
	public override func layoutSubviews() {
		if !isDefined {
			clearRow()
		}
		super.layoutSubviews()
	}

// MARK: Initialization
	public func define(shepard: Shepard?) {
		isDefined = true
		self.shepard = shepard
		setup()
	}

// MARK: Populate Data
	fileprivate func setup() {
		guard photoImageView != nil else { return }
		if !UIWindow.isInterfaceBuilder {
			Photo.addPhoto(from: shepard, toView: photoImageView, placeholder: UIImage.placeholder())
		}
		nameLabel?.text = shepard?.fullName ?? ""
		titleLabel?.text = shepard?.title
		dateLabel?.text = String(format: dateMessage, shepard?.modifiedDate.format(.typical) ?? "")

		layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	fileprivate func clearRow() {
		photoImageView?.image = nil
		nameLabel?.text = ""
		titleLabel?.text = ""
		dateLabel?.text = ""
	}
}
