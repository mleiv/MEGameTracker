//
//  ConversationRewardsDetailRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/11/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final class ConversationRewardsDetailRow: UITableViewCell {

// MARK: Types
// MARK: Constants

// MARK: Outlets
	@IBOutlet fileprivate weak var indentConstraint1: NSLayoutConstraint?
	@IBOutlet fileprivate weak var commonContextLabel: MarkupLabel?
	@IBOutlet fileprivate weak var optionsStack: UIStackView?

// MARK: Properties
	internal fileprivate(set) var conversationRewardsFlatData: ConversationRewards.FlatData?
	fileprivate var parent: ConversationRewardsDetailController?

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
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(
		data: ConversationRewards.FlatData?,
		parent: ConversationRewardsDetailController? = nil
	) {
		isDefined = true
		self.conversationRewardsFlatData = data
		self.parent = parent
		setup()
	}

// MARK: Populate Data
	fileprivate func setup() {
		guard indentConstraint1 != nil else { return }

		indentConstraint1?.constant = 0
		commonContextLabel?.isHidden = true
		optionsStack?.arrangedSubviews.forEach {
			$0.removeFromSuperview()
		}

		if let rewards = self.conversationRewardsFlatData {
			indentConstraint1?.constant = CGFloat(rewards.level * 15)

			commonContextLabel?.text = "\(rewards.commonContext ?? ""): "
			commonContextLabel?.isHidden = rewards.commonContext?.isEmpty ?? true

			for option in rewards.options {
				if let newRow = ConversationRewardDetailOption.loadNib(option: option, action: optionSelected) {
					optionsStack?.addArrangedSubview(newRow)
				}
			}
		}

		layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	fileprivate func clearRow() {
		commonContextLabel?.text = ""
	}

// MARK: Supporting Functions
	fileprivate func optionSelected(onButton: RadioButton?, id: String?) {
		if let id = id {
			for option in (conversationRewardsFlatData?.options ?? []) where id == option.id {
				parent?.saveConversationRewardsChoice(id: id, isOn: onButton != nil)
				break
			}
		}

//		if let button = onButton {
//			for optionRow in (optionsStack?.arrangedSubviews ?? []) {
//				if let stack = optionRow as? ConversationRewardDetailOption , button != stack.button {
//					stack.toggleOption(isOn: false)
//				}

//			}

//		}
	}

}
