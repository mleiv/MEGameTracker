//
//  ConversationRewardDetailOption.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/3/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final class ConversationRewardDetailOption: UIView {

// MARK: Types
	typealias ActionClosure = ((_ onButton: RadioButton?, _ id: String?) -> Void)
// MARK: Constants
	private let paragonMessage = "%@ Paragon: %@"
	private let renegadeMessage = "%@ Renegade: %@"
	private let creditsMessage = "%@ Credits: %@"
	private let paragadeMessage = "%@ Paragon / %@ Renegade: %@"
	private let reputationMessage = "%@ Reputation %@"

// MARK: Outlets
	@IBOutlet private weak var button: RadioButton?
	@IBOutlet private weak var contextLabel: MarkupLabel?
	@IBOutlet private weak var optionLabel: MarkupLabel?
	@IBAction private func selectOption(_ sender: AnyObject?) { toggleOption() }

// MARK: Properties
	internal fileprivate(set) var id: String?
	internal fileprivate(set) var option: ConversationRewards.FlatDataOption?
	private var action: ActionClosure?

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
	public class func loadNib(
		option: ConversationRewards.FlatDataOption,
		action: @escaping ActionClosure
	) -> ConversationRewardDetailOption? {
		//TODO: protocol this with a nibName property and setup func ?
		let bundle = Bundle(for: ConversationRewardDetailOption.self)
		if let view = bundle.loadNibNamed(
				"ConversationRewardDetailOption",
				owner: self, options: nil
			)?.first as? ConversationRewardDetailOption {
			view.define(option: option, action: action)
			return view
		}
		return nil
	}

	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(
		option: ConversationRewards.FlatDataOption,
		action: @escaping ActionClosure
	) {
		isDefined = true
		self.option = option
		self.id = option.id
		self.action = action
		setup()
	}

// MARK: Populate Data
	private func setup() {
		guard let option = self.option else { return }
		setStyle()
		contextLabel?.text = "\(option.context ?? ""): "
		contextLabel?.isHidden = option.context?.isEmpty ?? true
		optionLabel?.text = setLabelText(option: option)
		button?.toggle(isOn: option.isSelected)

		layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		button?.isOn = false
		contextLabel?.text = ""
		optionLabel?.text = ""
	}

// MARK: Accessible Functions
	internal func toggleOption(isOn: Bool? = nil) {
		let isTurnOn = isOn ?? !(button?.isOn ?? false)
		// propogate our whole-row click down to radio button value (since it is overridden)
		button?.toggle(isOn: isTurnOn)
		action?(isTurnOn ? button : nil, id)
	}

// MARK: Supporting Functions

	private func setStyle() {
		guard let option = self.option else { return }
		// only works if we set style before setting content text
		switch option.type {
			case .paragon: optionLabel?.identifier = "Caption.ParagonColor" //TODO: constants
			case .renegade: optionLabel?.identifier = "Caption.RenegadeColor"
			case .neutral: fallthrough
			case .paragade: optionLabel?.identifier = "Caption.ParagadeColor"
			case .credits: optionLabel?.identifier = "Caption.NormalColor.Medium"
		}
	}

	private func setLabelText(option: ConversationRewards.FlatDataOption) -> String {
		switch option.type {
			case .paragon: return String(format: paragonMessage, option.points, option.trigger)
			case .renegade: return String(format: renegadeMessage, option.points, option.trigger)
			case .credits: return String(format: creditsMessage, option.points, option.trigger)
			case .neutral: fallthrough
			case .paragade:
				var values = option.points.components(separatedBy: "/")
				if values.count == 2 {
					return String(format: paragadeMessage, values[0], values[1], option.trigger)
				} else {
					return String(format: reputationMessage, option.points, option.trigger)
				}
		}
	}

}
