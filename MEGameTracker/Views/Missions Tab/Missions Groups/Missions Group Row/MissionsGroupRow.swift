//
//  MissionRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class MissionsGroupRow: UITableViewCell {

// MARK: Constants
	var namePattern = "%@ (%d)"
	var descriptionPattern = "%d Completed, %d Unavailable"

// MARK: Outlets
	@IBOutlet weak var sizeWrapper: UIView?
	@IBOutlet weak var nameLabel: MarkupLabel?
	@IBOutlet weak var descriptionLabel: MarkupLabel?
	@IBOutlet weak var disclosureImageWrapper: UIView?
	@IBOutlet weak var disclosureImageView: UIImageView?

// MARK: Properties
	var name: String?
	var availableCount = 0
	var unavailableCount = 0
	var completedCount = 0

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
	func define(name: String, availableCount: Int, unavailableCount: Int, completedCount: Int) {
		isDefined = true
		self.name = name
		self.availableCount = availableCount
		self.unavailableCount = unavailableCount
		self.completedCount = completedCount
		setup()
	}

// MARK: Populate Data
	fileprivate func setup() {
		nameLabel?.text = String(format: namePattern, name ?? "", availableCount)
		nameLabel?.isEnabled = availableCount > 0
		descriptionLabel?.text = String(format: descriptionPattern, completedCount, unavailableCount)
		disclosureImageView?.isHidden = nameLabel?.isEnabled != true

		layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	fileprivate func clearRow() {
		nameLabel?.text = ""
		descriptionLabel?.text = ""
		disclosureImageView?.isHidden = true
	}

}
