//
//  PersonRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class PersonRow: UITableViewCell {

// MARK: Types
// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var photoImageView: UIImageView?

	@IBOutlet private weak var nameLabel: UILabel?
	@IBOutlet private weak var titleLabel: UILabel?
	@IBOutlet private weak var statusLabel: UILabel?
	@IBOutlet private weak var availabilityLabel: UILabel?
	@IBOutlet private weak var heartButton: HeartButton?

	@IBOutlet private weak var disclosureImageView: UIImageView?

// MARK: Properties
	internal fileprivate(set) var person: Person?
	internal fileprivate(set) var isLoveInterest: Bool = false
	private var hideDisclosure: Bool = false
	private var onChangeLoveSetting: ((_ sender: HeartButton) -> Void)?

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
	public func define(
		person: Person?,
		isLoveInterest: Bool = false,
		hideDisclosure: Bool = false,
		onChangeLoveSetting: ((HeartButton) -> Void)? = nil
	) {
		isDefined = true
		self.person = person
		self.isLoveInterest = isLoveInterest
		self.hideDisclosure = hideDisclosure
		self.onChangeLoveSetting = onChangeLoveSetting
		setup()
	}

// MARK: Populate Data
	private func setup() {
		guard photoImageView != nil else { return }

		nameLabel?.text = person?.name
		nameLabel?.isEnabled = person?.isAvailable ?? false

		Photo.addPhoto(from: person, toView: photoImageView, placeholder: UIImage.placeholderThumbnail())

		statusLabel?.isHidden = true // TODO

		if person?.isAvailable != true {
			availabilityLabel?.text = person?.getUnavailabilityMessages().joined(separator: ", ")
			availabilityLabel?.isHidden = availabilityLabel?.text?.isEmpty ?? true
			statusLabel?.isHidden = true
		} else {
//			statusLabel?.text = person?.status
			availabilityLabel?.isHidden = true
		}
		titleLabel?.text = person?.title
		heartButton?.isParamour = person?.isParamour ?? true
		heartButton?.isHidden = person?.isAvailableLoveInterest != true
		heartButton?.toggle(isOn: isLoveInterest)
		heartButton?.onClick = changeLoveSetting
		disclosureImageView?.isHidden = hideDisclosure
		selectionStyle = hideDisclosure ? .none : .default
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		photoImageView?.image = nil
		nameLabel?.text = " "
		titleLabel?.text = " "
		statusLabel?.text = " "
		availabilityLabel?.text = " "
		heartButton?.isOn = false
	}

// MARK: Supporting Functions
	private func changeLoveSetting(_ sender: AnyObject?) {
		isLoveInterest = heartButton?.isOn ?? false
		heartButton?.toggle(isOn: isLoveInterest)
		if let heartButton = heartButton {
			onChangeLoveSetting?(heartButton)
		}
	}
}
