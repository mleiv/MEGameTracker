//
//  CalloutBalloon.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/9/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public struct CalloutBalloon {

	public enum TailDirection { case up, down, right, left }

	weak var baseLayer: CALayer?
	weak var visibleWrapper: UIView?
	weak var sizeWrapper: UIView?
	let tailDirection: TailDirection
	let tailLength: CGFloat
	let tailWidth: CGFloat
	let borderWidth: CGFloat
	var cornerRadius: CGFloat
	let borderColor: UIColor
	let backgroundColor: UIColor

	var innerLayer: CAShapeLayer?
	var outerLayer: CAShapeLayer?

	public init(
		baseLayer: CALayer?,
		visibleWrapper: UIView?,
		sizeWrapper: UIView?,
		tailDirection: TailDirection = .up,
		tailLength: CGFloat = 20.0,
		tailWidth: CGFloat = 10.0,
		borderWidth: CGFloat = 1.0,
		cornerRadius: CGFloat = 5.0,
		borderColor: UIColor = .black,
		backgroundColor: UIColor = .white
	) {
		self.baseLayer = baseLayer
		self.visibleWrapper = visibleWrapper
		self.sizeWrapper = sizeWrapper
		self.tailDirection = tailDirection
		self.tailLength = tailLength
		self.tailWidth = tailWidth
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
		self.borderColor = borderColor
		self.backgroundColor = backgroundColor
	}

	public mutating func render() {
		createLayers()
		positionLayers()
		drawLayers()
	}

	private mutating func createLayers() {
		guard let sizeWrapper = self.sizeWrapper else { return }
		// add necessary layers
		innerLayer = CAShapeLayer()
		outerLayer = CAShapeLayer()
		let bounds = sizeWrapper.bounds
		innerLayer?.frame = bounds
		outerLayer?.frame = bounds
	}

	private func positionLayers() {
		guard let sizeWrapper = self.sizeWrapper else { return }
		// now offset for arrow (otherwise its border color gets clipped off)
		let x = sizeWrapper.frame.origin.x
		let y = sizeWrapper.frame.origin.y
		outerLayer?.frame.origin.x = x
		outerLayer?.frame.origin.y = y
		innerLayer?.frame.origin.x = x
		innerLayer?.frame.origin.y = y
	}

	private func drawLayers() {
		let outerPath = UIBezierPath()
		let innerPath = UIBezierPath()

		drawBalloon(outerPath: outerPath, innerPath: innerPath)

		innerLayer?.path = innerPath.cgPath
		visibleWrapper?.layer.backgroundColor = backgroundColor.cgColor
		visibleWrapper?.layer.mask = innerLayer

		outerLayer?.path = outerPath.cgPath
		baseLayer?.backgroundColor = borderColor.cgColor
		baseLayer?.mask = outerLayer
	}

	// swiftlint:disable function_body_length
	private func drawBalloon(outerPath: UIBezierPath, innerPath: UIBezierPath) {
		guard let sizeWrapper = self.sizeWrapper else { return }
		let bounds = sizeWrapper.bounds

		outerPath.move(to: CGPoint(x: cornerRadius, y: 0))
		innerPath.move(to: CGPoint(x: cornerRadius + borderWidth, y: 0 + borderWidth))
		if tailDirection == .up {
			drawTail(outerPath: outerPath, innerPath: innerPath)
		}
		let topRight = CGPoint(x: bounds.width, y: 0)
		let topRight1 = CGPoint(x: bounds.width - cornerRadius, y: 0)
		let topRight2 = CGPoint(x: bounds.width, y: cornerRadius)
		let topRightInner = CGPoint(x: bounds.width - (borderWidth / 2), y: 0 + (borderWidth / 2))
		let topRightInner1 = CGPoint(x: (bounds.width - cornerRadius) - borderWidth, y: 0 + borderWidth)
		let topRightInner2 = CGPoint(x: bounds.width - borderWidth, y: cornerRadius + borderWidth)
		outerPath.addLine(to: topRight1)
		innerPath.addLine(to: topRightInner1)
		outerPath.addQuadCurve(to: topRight2, controlPoint: topRight)
		innerPath.addQuadCurve(to: topRightInner2, controlPoint: topRightInner)
		if 	tailDirection == .right {
			drawTail(outerPath: outerPath, innerPath: innerPath)
		}
		let bottomRight = CGPoint(x: bounds.width, y: bounds.height)
		let bottomRight1 = CGPoint(x: bounds.width, y: bounds.height - cornerRadius)
		let bottomRight2 = CGPoint(x: bounds.width - cornerRadius, y: bounds.height)
		let bottomRightInner = CGPoint(x: bounds.width - (borderWidth / 2), y: bounds.height - (borderWidth / 2))
		let bottomRightInner1 = CGPoint(x: bounds.width - borderWidth, y: bounds.height - cornerRadius - borderWidth)
		let bottomRightInner2 = CGPoint(x: bounds.width - cornerRadius - borderWidth, y: bounds.height - borderWidth)
		outerPath.addLine(to: bottomRight1)
		innerPath.addLine(to: bottomRightInner1)
		outerPath.addQuadCurve(to: bottomRight2, controlPoint: bottomRight)
		innerPath.addQuadCurve(to: bottomRightInner2, controlPoint: bottomRightInner)
		if tailDirection == .down {
			drawTail(outerPath: outerPath, innerPath: innerPath)
		}
		let bottomLeft = CGPoint(x: 0, y: bounds.height)
		let bottomLeft1 = CGPoint(x: cornerRadius, y: bounds.height)
		let bottomLeft2 = CGPoint(x: 0, y: bounds.height - cornerRadius)
		let bottomLeftInner = CGPoint(x: 0 + (borderWidth / 2), y: bounds.height - (borderWidth / 2))
		let bottomLeftInner1 = CGPoint(x: cornerRadius + borderWidth, y: bounds.height - borderWidth)
		let bottomLeftInner2 = CGPoint(x: 0 + borderWidth, y: bounds.height - cornerRadius - borderWidth)
		outerPath.addLine(to: bottomLeft1)
		innerPath.addLine(to: bottomLeftInner1)
		outerPath.addQuadCurve(to: bottomLeft2, controlPoint: bottomLeft)
		innerPath.addQuadCurve(to: bottomLeftInner2, controlPoint: bottomLeftInner)
		if tailDirection == .left {
			drawTail(outerPath: outerPath, innerPath: innerPath)
		}
		let topLeft = CGPoint(x: 0, y: 0)
		let topLeft1 = CGPoint(x: 0, y: cornerRadius)
		let topLeft2 = CGPoint(x: cornerRadius, y: 0)
		let topLeftInner = CGPoint(x: 0 + (borderWidth / 2), y: 0 + (borderWidth / 2))
		let topLeftInner1 = CGPoint(x: 0 + borderWidth, y: cornerRadius + borderWidth)
		let topLeftInner2 = CGPoint(x: cornerRadius + borderWidth, y: 0 + borderWidth)
		outerPath.addLine(to: topLeft1)
		innerPath.addLine(to: topLeftInner1)
		outerPath.addQuadCurve(to: topLeft2, controlPoint: topLeft)
		innerPath.addQuadCurve(to: topLeftInner2, controlPoint: topLeftInner)

		outerPath.close()
		innerPath.close()
	}
	// swiftlint:enable function_body_length

	// swiftlint:disable function_body_length
	private func drawTail(outerPath: UIBezierPath, innerPath: UIBezierPath) {
		guard let sizeWrapper = self.sizeWrapper else { return }
		let bounds = sizeWrapper.bounds

		let tailInnerWidth = tailWidth - (borderWidth * 2)
		var lineBreak = CGPoint(x: (bounds.width - tailWidth) / 2, y: (bounds.height - tailWidth) / 2)
		var lineBreakInner = CGPoint(
			x: (bounds.width - tailInnerWidth) / 2,
			y: (bounds.height - tailInnerWidth) / 2
		)
		var tailPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
		var tailPointInner = CGPoint(x: tailPoint.x, y: tailPoint.y)
		switch tailDirection {
			case .up:
				lineBreak.y = 0 // top side
				lineBreakInner.y = lineBreak.y + borderWidth
				tailPoint.y = lineBreak.y - tailLength // above top
				tailPointInner.y = tailPoint.y + (borderWidth * 2)
			case .right:
				lineBreak.x = bounds.width // right side
				lineBreakInner.x = lineBreak.x - borderWidth
				tailPoint.x = lineBreak.x + tailLength // right of right
				tailPointInner.x = tailPoint.x - (borderWidth * 2)
			case .down:
				lineBreak.x += tailWidth
				lineBreak.y = bounds.height // bottom side
				lineBreakInner.x += tailInnerWidth
				lineBreakInner.y = lineBreak.y - borderWidth
				tailPoint.y = lineBreak.y + tailLength // below bottom
				tailPointInner.y = tailPoint.y - (borderWidth * 2)
			case .left:
				lineBreak.y += tailWidth
				lineBreak.x = 0 // left side
				lineBreakInner.y += tailInnerWidth
				lineBreakInner.x = lineBreak.x + borderWidth
				tailPoint.x = lineBreak.x - tailLength // left of left
				tailPointInner.x = tailPoint.x + (borderWidth * 2)
		}
		outerPath.addLine(to: lineBreak)
		innerPath.addLine(to: lineBreakInner)
		outerPath.addLine(to: tailPoint)
		innerPath.addLine(to: tailPointInner)
		if tailDirection == .up || tailDirection == .down {
			lineBreak.x += tailWidth * (tailDirection == .up ? 1 : -1)
			lineBreakInner.x += tailInnerWidth * (tailDirection == .up ? 1 : -1)
		} else {
			lineBreak.y += tailWidth * (tailDirection == .right ? 1 : -1)
			lineBreakInner.y += tailInnerWidth * (tailDirection == .right ? 1 : -1)
		}
		outerPath.addLine(to: lineBreak)
		innerPath.addLine(to: lineBreakInner)
	}
	// swiftlint:enable function_body_length

}
