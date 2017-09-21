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
	private let dateMessage = "Last Played: %@"

// MARK: Outlets
	@IBOutlet private weak var photoImageView: UIImageView?
	@IBOutlet private weak var nameLabel: UILabel?
	@IBOutlet private weak var titleLabel: UILabel?
	@IBOutlet private weak var dateLabel: UILabel?

// MARK: Properties
	internal fileprivate(set) var shepard: Shepard?

// MARK: Change Listeners And Change Status Flags
	private var isDefined = false

// MARK: Lifecycle Events
	public override func layoutSubviews() {
		if !isDefined {
			clearRow()
		}
		super.layoutSubviews()
	}

// MARK: Initialization
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(shepard: Shepard?) {
		isDefined = true
		self.shepard = shepard
		setup()
	}

// MARK: Populate Data
	private func setup() {
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
	private func clearRow() {
		photoImageView?.image = nil
		nameLabel?.text = ""
		titleLabel?.text = ""
		dateLabel?.text = ""
	}
}
