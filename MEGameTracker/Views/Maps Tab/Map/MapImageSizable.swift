//
//  MapImageSizable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/29/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol MapImageSizable: class {
	var map: Map? { get }
	var mapImageScrollView: UIScrollView? { get }
	var mapImageScrollHeightConstraint: NSLayoutConstraint? { get set }
	var mapImageWrapperView: UIView? { get set }
	var lastMapImageName: String? { get set }
	func setupMapImage(baseView: UIView?, competingView: UIView?)
	func resizeMapImage(baseView: UIView?, competingView: UIView?)
}

extension MapImageSizable {

	public func setupMapImage(baseView: UIView?, competingView: UIView?) {
		guard map?.image?.isEmpty == false,
			let mapImageWrapperView = mapImageWrapper() else { return }
		self.mapImageWrapperView = mapImageWrapperView

		// clean old subviews
		mapImageScrollView?.subviews.forEach { $0.removeFromSuperview() }

		// size scrollView
		mapImageScrollView?.contentSize = mapImageWrapperView.bounds.size
		mapImageScrollView?.addSubview(mapImageWrapperView)
//		mapImageWrapperView.fillView(mapImageScrollView) // don't do this!

		sizeMapImage(baseView: baseView, competingView: competingView)

		shiftMapImage(baseView: baseView, competingView: competingView)
	}

	public func resizeMapImage(baseView: UIView?, competingView: UIView?) {
		sizeMapImage(baseView: baseView, competingView: competingView)
		shiftMapImage(baseView: baseView, competingView: competingView)
	}

	private func sizeMapImage(baseView: UIView?, competingView: UIView?) {
		if mapImageScrollHeightConstraint == nil {
			mapImageScrollHeightConstraint = mapImageScrollView?.superview?.heightAnchor
				.constraint(equalToConstant: 10000)
			mapImageScrollHeightConstraint?.isActive = true
		} else {
			mapImageScrollHeightConstraint?.constant = 10000
		}
		guard
			let mapImageScrollView = mapImageScrollView,
			let mapImageScrollHeightConstraint = mapImageScrollHeightConstraint,
			let _ = mapImageWrapperView
		else {
			return
		}
        baseView?.layoutIfNeeded()
		mapImageScrollView.superview?.isHidden = false
		let maxHeight = (baseView?.bounds.height ?? 0) - (competingView?.bounds.height ?? 0)
		mapImageScrollHeightConstraint.constant = maxHeight
        mapImageScrollView.superview?.layoutIfNeeded()
		mapImageScrollView.minimumZoomScale = currentImageRatio(
			baseView: baseView,
			competingView: competingView
		) ?? 0.01
		mapImageScrollView.maximumZoomScale = 10
		mapImageScrollView.zoomScale = mapImageScrollView.minimumZoomScale
	}

	private func mapImageWrapper() -> UIView? {
		if lastMapImageName == map?.image && self.mapImageWrapperView != nil {
			return self.mapImageWrapperView
		} else {
			// clear out old values
			self.mapImageWrapperView?.subviews.forEach { $0.removeFromSuperview() }
		}
		guard let filename = map?.image,
			  let basePath = Bundle.currentAppBundle.path(forResource: "Maps", ofType: nil),
			  let pdfView = UIPDFView(url: URL(fileURLWithPath: basePath).appendingPathComponent(filename))
		else {
			return nil
		}
		let mapImageWrapperView = UIView(frame: pdfView.bounds)
		mapImageWrapperView.accessibilityIdentifier = "Map Image"
		mapImageWrapperView.addSubview(pdfView)
		lastMapImageName = map?.image
		return mapImageWrapperView
	}

	private func shiftMapImage(baseView: UIView?, competingView: UIView?) {
		guard let mapImageScrollView = mapImageScrollView,
			let mapImageWrapperView = mapImageWrapperView,
			let currentImageRatio = currentImageRatio(baseView: baseView, competingView: competingView) else { return }
		// center in window
		let differenceX: CGFloat = {
			let x = mapImageScrollView.bounds.width - (mapImageWrapperView.bounds.width * currentImageRatio)
			return max(0, x)
		}()
		mapImageScrollView.contentInset.left = floor(differenceX / 2)
		mapImageScrollView.contentInset.right = mapImageScrollView.contentInset.left
		let differenceY: CGFloat = {
			let y = mapImageScrollView.bounds.height - (mapImageWrapperView.bounds.height * currentImageRatio)
			return max(0, y)
		}()
		mapImageScrollView.contentInset.top = floor(differenceY / 2)
		mapImageScrollView.contentInset.bottom = mapImageScrollView.contentInset.top
	}

	private func currentImageRatio(baseView: UIView?, competingView: UIView?) -> CGFloat? {
		guard
			let mapImageWrapperView = self.mapImageWrapperView,
			mapImageWrapperView.bounds.height > 0
		else {
			return nil
		}
		let maxWidth = baseView?.bounds.width ?? 0
		let maxHeight = (baseView?.bounds.height ?? 0) - (competingView?.bounds.height ?? 0)
		return min(maxWidth / mapImageWrapperView.bounds.width, maxHeight / mapImageWrapperView.bounds.height)
	}
}
