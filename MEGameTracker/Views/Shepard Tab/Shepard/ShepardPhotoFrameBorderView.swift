//
//  ShepardPhotoFrameBorderView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/19/20.
//  Copyright © 2020 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable
class ShepardPhotoFrameBorderView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 10
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        let maskLayer = CAShapeLayer()
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight, .bottomLeft],
                                    cornerRadii: CGSize(width: cornerRadius, height: 0.0))
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
