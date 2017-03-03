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
    fileprivate let paragonMessage = "%@ Paragon: %@"
    fileprivate let renegadeMessage = "%@ Renegade: %@"
    fileprivate let creditsMessage = "%@ Credits: %@"
    fileprivate let paragadeMessage = "%@ Paragon / %@ Renegade: %@"
    
// MARK: Outlets
    @IBOutlet fileprivate weak var button: RadioButton?
    @IBOutlet fileprivate weak var contextLabel: MarkupLabel?
    @IBOutlet fileprivate weak var optionLabel: MarkupLabel?
    @IBAction fileprivate func selectOption(_ sender: AnyObject?) { toggleOption() }
    
// MARK: Properties
    internal fileprivate(set) var id: String?
    internal fileprivate(set) var option: ConversationRewards.FlatDataOption?
    fileprivate var action: ActionClosure?
    
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
    public class func loadNib(option: ConversationRewards.FlatDataOption, action: @escaping ActionClosure) -> ConversationRewardDetailOption? {
        //TODO: protocol this with a nibName property and setup func ?
        let bundle = Bundle(for: ConversationRewardDetailOption.self)
        if let view = bundle.loadNibNamed("ConversationRewardDetailOption", owner: self, options: nil)?.first as? ConversationRewardDetailOption {
            view.define(option: option, action: action)
            return view
        }
        return nil
    }
    
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
    fileprivate func setup() {
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
    fileprivate func clearRow() {
        button?.isOn = false
        contextLabel?.text = ""
        optionLabel?.text = ""
    }

// MARK: Accessible Functions
    internal func toggleOption(isOn: Bool? = nil) {
        let isTurnOn = isOn ?? !(button?.isOn ?? false)
        button?.toggle(isOn: isTurnOn) // propogate our whole-row click down to radio button value (since it is overridden)
        action?(isTurnOn ? button : nil, id)
    }
    
// MARK: Supporting Functions
    
    fileprivate func setStyle() {
        guard let option = self.option else { return }
        // only works if we set style before setting content text
        switch option.type {
            case .paragon: optionLabel?.identifier = "Caption.ParagonColor" //TODO: constants
            case .renegade: optionLabel?.identifier = "Caption.RenegadeColor"
            case .paragade: optionLabel?.identifier = "Caption.ParagadeColor"
            case .credits: optionLabel?.identifier = "Caption.NormalColor.Medium"
        }
    }
    
    fileprivate func setLabelText(option: ConversationRewards.FlatDataOption) -> String {
        switch option.type {
            case .paragon: return String(format: paragonMessage, option.points, option.trigger)
            case .renegade: return String(format: renegadeMessage, option.points, option.trigger)
            case .credits: return String(format: creditsMessage, option.points, option.trigger)
            case .paragade:
                var values = option.points.components(separatedBy: "/")
                while values.count < 2 { values.append("0") }
                return String(format: paragadeMessage, values[0], values[1], option.trigger)
        }
    }
    
}
