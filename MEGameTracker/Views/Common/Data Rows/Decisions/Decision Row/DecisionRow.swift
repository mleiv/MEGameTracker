//
//  DecisionRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class DecisionRow: UITableViewCell {

// MARK: Types
// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var stack: UIStackView?

	@IBOutlet private weak var radioButton: RadioButton?
	@IBOutlet private weak var titleLabel: MarkupLabel?
	@IBOutlet private weak var gameLabel: UILabel?

	@IBAction private func onChange(_ sender: AnyObject?) { toggleDecision() }

// MARK: Properties
	internal fileprivate(set) var decision: Decision?
	private var isShowGameVersion: Bool = false

// MARK: Change Listeners And Change Status Flags
	internal var isDefined = false

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
	public func define(
		decision: Decision?,
		isShowGameVersion: Bool = true
	) {
		isDefined = true
		self.decision = decision
		self.isShowGameVersion = isShowGameVersion
		setup()
	}

// MARK: Populate Data
	private func setup() {
		guard radioButton != nil else { return }
		radioButton?.toggle(isOn: decision?.isSelected ?? false)
		titleLabel?.text = decision?.name
		titleLabel?.isEnabled = decision?.isAvailable ?? false
		gameLabel?.text = decision?.gameVersion.headingValue
		gameLabel?.isHidden = !isShowGameVersion
        layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		radioButton?.isOn = false
		titleLabel?.text = ""
		gameLabel?.text = ""
	}

// MARK: Supporting Functions
	private func toggleDecision() {
		let isSelected = !(radioButton?.isOn == true)
		radioButton?.toggle(isOn: isSelected)
		DispatchQueue.global(qos: .background).async {
			_ = self.decision?.changed(isSelected: isSelected, isSave: true)
		}
	}

}
