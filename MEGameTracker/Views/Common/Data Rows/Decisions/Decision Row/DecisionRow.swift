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
    @IBOutlet fileprivate weak var stack: UIStackView?

    @IBOutlet fileprivate weak var radioButton: RadioButton?
    @IBOutlet fileprivate weak var titleLabel: MarkupLabel?
    @IBOutlet fileprivate weak var gameLabel: IBStyledLabel?
    
    @IBAction fileprivate func onChange(_ sender: AnyObject?) { toggleDecision() }
    
// MARK: Properties
    internal fileprivate(set) var decision: Decision?
    fileprivate var isShowGameVersion: Bool = false
    
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
    fileprivate func setup() {
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
    fileprivate func clearRow() {
        radioButton?.isOn = false
        titleLabel?.text = ""
        gameLabel?.text = ""
    }
    
// MARK: Supporting Functions
    fileprivate func toggleDecision() {
        let isSelected = !(radioButton?.isOn == true)
        radioButton?.toggle(isOn: isSelected)
        DispatchQueue.global(qos: .background).async {
            self.decision?.change(isSelected: isSelected, isSave: true)
        }
    }

}
