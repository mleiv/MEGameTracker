//
//  SliderRowView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final public class SliderRowView: UIView {

    @IBInspectable public var showRowDivider: Bool = false
    
    @IBInspectable public var borderTop: Bool = false {
        didSet {
            nib?.top = borderTop
        }
    }
    @IBInspectable public var borderBottom: Bool = false {
        didSet {
            nib?.bottom = borderBottom
        }
    }

    
    var value: Int = 1
    var minValue: Int = 0
    var maxValue: Int = 1
    var labelPattern = "%d/%d: "
    var onChange: ((_ value: Int) -> Void) = { _ in }
    
    var nib: SliderRowNib?
    
//    var didSetup = false
//    public override func layoutSubviews() {
//        if !didSetup {
//            setup()
//        }
//        super.layoutSubviews()
//    }
    public func setup(value: Int, minValue: Int, maxValue: Int, labelPattern: String? = nil, onChange: ((_ value: Int) -> Void)? = nil) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.labelPattern = labelPattern ?? self.labelPattern
        self.onChange = onChange ?? self.onChange
        setupRow()
    }
    
    func setupRow() {
        if nib == nil, let view = SliderRowNib.loadNib() {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
        }
        if let view = nib {
            
            view.rowDivider?.isHidden = !showRowDivider
            view.onChangeBlock = sliderChanged
            view.onFinishedChangeBlock = sliderFinishedChanging
            
            setupValues()
            
            // no hide row option for this?
            
//            didSetup = true
            layoutIfNeeded()
        }
    }
    
    func setupValues() {
        nib?.slider?.minimumValue = Float(minValue)
        nib?.slider?.maximumValue = Float(maxValue)
        nib?.slider?.value = Float(value)
        nib?.headingLabel?.text = String(format: labelPattern, value, maxValue)
    }
    
    public func sliderChanged(_ sender: UIView?) {
        let maxValue = App.current.gameVersion.maxShepardLevel
        let value = Int((sender as? UISlider)?.value ?? 1)
        nib?.headingLabel?.text = String(format: labelPattern, value, maxValue)
    }
    
    public func sliderFinishedChanging(_ sender: UIView?) {
        let value = Int((sender as? UISlider)?.value ?? 1)
        onChange(value)
    }
}


