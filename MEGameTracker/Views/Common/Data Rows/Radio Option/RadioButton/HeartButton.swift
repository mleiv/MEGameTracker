//
//  HeartButton.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/7/2015.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable final public class HeartButton: RadioButton {
    static let uncheckedImage = UIImage(named: "Heart Empty", in: Bundle(for: HeartButton.self), compatibleWith: nil)
    static let checkedImage = UIImage(named: "Heart Filled", in: Bundle(for: HeartButton.self), compatibleWith: nil)
    
    override open func setup() {
        if nib == nil, let view = RadioButtonNib.loadNib(onImage: HeartButton.checkedImage, offImage: HeartButton.uncheckedImage) {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
        }
        if let view = nib {
            view.radioOn?.isHidden = !isOn
            view.alpha = enabled ? 1.0 : 0.5
            view.parent = self
            didSetup = true
//            layoutIfNeeded()
        }
    }
}
