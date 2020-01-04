//
//  HairlineBorderView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/9/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable
open class HairlineBorderView: UIView {
	@IBInspectable open var color: UIColor = UIColor.separator
	@IBInspectable open var top: Bool = false
	@IBInspectable open var bottom: Bool = false
	@IBInspectable open var left: Bool = false
	@IBInspectable open var right: Bool = false

	var borderLayer: CAShapeLayer?
	var isDrawing = false

	open override func layoutSubviews() {
		if !isDrawing {
			drawBorders()
		}
	}

	open func reset(top: Bool, bottom: Bool, left: Bool, right: Bool) {
		self.top = top
		self.bottom = bottom
		self.left = left
		self.right = right
		drawBorders()
	}

	func drawBorders() {
		isDrawing = true
		let hairline = CGFloat(1.0) / UIScreen.main.scale
		if borderLayer == nil {
			let borderLayer = CAShapeLayer()
			borderLayer.lineWidth = hairline
			borderLayer.strokeColor = color.cgColor
			borderLayer.fillColor = UIColor.clear.cgColor
			layer.addSublayer(borderLayer)
			self.borderLayer = borderLayer
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
		isDrawing = false
	}
}
