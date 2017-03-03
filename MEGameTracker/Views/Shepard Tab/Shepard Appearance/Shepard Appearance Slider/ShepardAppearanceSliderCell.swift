//
//  ShepardAppearanceSliderCell.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/24/2016.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ShepardAppearanceSliderCell: UITableViewCell {

// MARK: Types
    public typealias OnAppearanceSliderChange = ((_ attribute: Shepard.Appearance.AttributeType, _ value: Int) -> Void)
    
// MARK: Constants
// MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!

// MARK: Properties
    var attributeType: Shepard.Appearance.AttributeType?
    var value: Int?
    var maxValue: Int = 0
    var title: String?
    var notice: String?
    var error: String?
    var onChange: OnAppearanceSliderChange?
    
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
    public func define(
        attributeType: Shepard.Appearance.AttributeType?,
        value: Int? = nil,
        maxValue: Int? = 0,
        title: String?,
        notice: String? = nil,
        error: String? = nil,
        onChange: OnAppearanceSliderChange? = nil
    ) {
        isDefined = true
        self.attributeType = attributeType
        self.value = value ?? self.value
        self.maxValue = maxValue ?? self.maxValue
        self.title = title
        self.notice = notice
        self.error = error
        self.onChange = onChange
        setup()
    }
    
// MARK: Populate Data
    fileprivate func setup() {
        guard titleLabel != nil else { return }
        titleLabel?.text = "\(title ?? "?"):"
        let valueString = value != nil ? "\(value!)" : "?"
        sliderValueLabel?.text = "\(valueString)/\(maxValue)"
        slider?.minimumValue = 1
        slider?.maximumValue = Float(maxValue)
        slider?.value = min(slider.maximumValue, Float(value ?? 0))
        slider?.addTarget(self, action: #selector(ShepardAppearanceSliderCell.sliderChanged(_:)), for: UIControlEvents.valueChanged)
        noticeLabel?.text = notice
        noticeLabel?.isHidden = !(notice?.isEmpty == false)
        errorLabel?.text = error
        errorLabel?.isHidden = !(error?.isEmpty == false)
        
        layoutIfNeeded()
    }
    
    /// Resets all text in the cases where row UI loads before data/setup.
    /// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
    fileprivate func clearRow() {
        titleLabel?.text = ""
        sliderValueLabel?.text = ""
        slider?.minimumValue = 0.0
        slider?.maximumValue = 0.0
        slider?.value = 0.0
        noticeLabel?.isHidden = true
        errorLabel?.isHidden = true
    }
    
// MARK: Supporting Functions
    func sliderChanged(_ sender: UISlider) {
        value = Int(sender.value)
        sender.value = Float(value ?? 0)
        let valueString = value != nil ? "\(value!)" : "?"
        sliderValueLabel?.text = "\(valueString)/\(maxValue)"
        if let attributeType = self.attributeType, let value = self.value {
            onChange?(attributeType, value)
        }
    }
}
 
