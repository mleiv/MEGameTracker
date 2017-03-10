//
//  NoteRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/8/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final class NoteRow: UITableViewCell {

// MARK: Types
// MARK: Constants
	fileprivate let gameLabelMessage = " - %@ (Game %@)"

// MARK: Outlets
	@IBOutlet fileprivate weak var noteTextView: IBStyledTextView?
	@IBOutlet fileprivate weak var dateLabel: IBStyledLabel?
	@IBOutlet fileprivate weak var gameLabel: IBStyledLabel?

// MARK: Properties
	internal fileprivate(set) var note: Note?

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
	public func define(note: Note?) {
		isDefined = true
		self.note = note
		setup()
	}

// MARK: Populate Data
	fileprivate func setup() {
		guard noteTextView != nil else { return }
		noteTextView?.text = note?.text
		noteTextView?.sizeToFit()
		noteTextView?.isUserInteractionEnabled = false
		dateLabel?.text = note?.createdDate.format(.typical)
		if UIWindow.isInterfaceBuilder {
			gameLabel?.text = String(format: gameLabelMessage, "John Shepard", "\(1)")
		} else if let shepardUuid = note?.shepardUuid, let shepard = getShepard(uuid: shepardUuid) {
			gameLabel?.text = String(format: gameLabelMessage, shepard.fullName, "\(shepard.gameVersion.stringValue)")
		} else {
			gameLabel?.text = ""
		}

		layoutIfNeeded()
	}

	private func getShepard(uuid: String?) -> Shepard? {
		if App.current.game?.shepard?.uuid == uuid {
			return App.current.game?.shepard
		}
		if let uuid = uuid {
			return Shepard.get(uuid: uuid)
		}
		return nil
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	fileprivate func clearRow() {
		noteTextView?.text = ""
		dateLabel?.text = ""
		gameLabel?.text = ""
	}
}
