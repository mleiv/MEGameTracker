//
//  HairlineBorderView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/9/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable
open class BorderView: UIView {
    @IBInspectable open var color: UIColor = UIColor.clear
    @IBInspectable open var top: Bool = true
    @IBInspectable open var bottom: Bool = true
    @IBInspectable open var left: Bool = true
    @IBInspectable open var right: Bool = true
    
    var borderLayer: CAShapeLayer?

    open override func layoutSubviews() {
        super.layoutSubviews()
        drawBorders()
    }
    
    func drawBorders() {
        let hairline = CGFloat(1.0)
        if borderLayer == nil {
            borderLayer = CAShapeLayer()
            borderLayer?.lineWidth = hairline
            borderLayer?.strokeColor = color.cgColor
            borderLayer?.fillColor = UIColor.clear.cgColor
            layer.addSublayer(borderLayer!)
        }
        let path = UIBezierPath()
        let hairlinePosition = hairline / CGFloat(2.0)
        if top == true {
            path.move(to: CGPoint(x: 0, y: 0 - hairlinePosition))
            path.addLine(to: CGPoint(x: frame.size.width, y: 0 - hairlinePosition))
        }
        if bottom == true {
            path.move(to: CGPoint(x: 0, y: frame.size.height + hairlinePosition))
            path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height + hairlinePosition))
        }
        if left == true {
            path.move(to: CGPoint(x: 0 - hairlinePosition, y: 0))
            path.addLine(to: CGPoint(x: 0 - hairlinePosition, y: frame.size.height))
        }
        if right == true {
            path.move(to: CGPoint(x: frame.size.width + hairlinePosition, y: 0))
            path.addLine(to: CGPoint(x: frame.size.width + hairlinePosition, y: frame.size.height))
        }
        borderLayer?.frame = bounds
        borderLayer?.path = path.cgPath
        borderLayer?.zPosition = CGFloat(layer.sublayers?.count ?? 0)
    }
}
