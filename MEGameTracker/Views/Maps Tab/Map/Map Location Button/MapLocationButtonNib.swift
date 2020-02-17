//
//  MapLocationButtonNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/15/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

final public class MapLocationButtonNib: UIView {

	private let minSize = CGSize(width: 25.0, height: 25.0)
	private let minVisibleSize = CGSize(width: 7.0, height: 7.0)

	@IBOutlet public weak var title: UILabel?
	@IBOutlet public weak var titleWidthConstraint: NSLayoutConstraint?
	@IBOutlet public weak var button: MapLocationButton?
	@IBOutlet public weak var buttonWidthConstraint: NSLayoutConstraint?
	@IBOutlet public weak var buttonHeightConstraint: NSLayoutConstraint?

//	@IBAction func buttonClicked(_ sender: MapLocationButton) {
//		onClick?(self)
//	}

	private var centerXConstraint: NSLayoutConstraint?
	private var centerYConstraint: NSLayoutConstraint?
	private var visibleView: UIView?
	private var visibleWidthConstraint: NSLayoutConstraint?
	private var visibleHeightConstraint: NSLayoutConstraint?

	public var mapLocationPoint: MapLocationPoint?
	public var sizedMapLocationPoint: MapLocationPoint?
	public var pinColor = UIColor.clear
    private let unavailablePinColor = UIColor.systemGray
//	public var onClick: ((MapLocationButtonNib) -> Void)?
	public var isShowPin = false {
		didSet { setVisible() }
	}
	public var zoomScale: CGFloat = 1.0 {
		didSet { size() }
	}

	public override func didMoveToSuperview() {
		size()
	}

	public func set(location: MapLocationable, isShowPin: Bool = false) {
		mapLocationPoint = location.mapLocationPoint
        title?.text = location.mapLocationType == .map ? location.name : nil
        if let mission = location as? Mission, !mission.isAvailableAndParentAvailable
            && (pinColor == UIColor.clear || pinColor == unavailablePinColor) {
            pinColor = unavailablePinColor
        } else {
            pinColor = (location as? Item)?.itemDisplayType?.color ?? MEGameTrackerColor.renegade
        }
		self.isShowPin = isShowPin
	}

	public func size(isForce: Bool = false) {
		guard let wrapper = superview, let mapLocationPoint = self.sizedMapLocationPoint else { return }

		translatesAutoresizingMaskIntoConstraints = false
		if isForce {
			centerXConstraint?.isActive = false
			centerXConstraint = nil
			centerYConstraint?.isActive = false
			centerYConstraint = nil
		}
		if centerXConstraint == nil && centerYConstraint == nil {
			centerXConstraint = centerXAnchor.constraint(equalTo: wrapper.leftAnchor, constant: mapLocationPoint.x)
			centerXConstraint?.isActive = true
			centerYConstraint = centerYAnchor.constraint(equalTo: wrapper.topAnchor, constant: mapLocationPoint.y)
			centerYConstraint?.isActive = true
		}

		let useZoomScale: CGFloat = max(zoomScale, 1.0)
		// only scale if we are drawing the shape, otherwise stick to map dimensions given.

		let baseWidth = mapLocationPoint.width
		let useWidth = max(minSize.width / max(useZoomScale, 1.0), baseWidth)
		if buttonWidthConstraint == nil {
			buttonWidthConstraint = widthAnchor.constraint(equalToConstant: useWidth)
			buttonWidthConstraint?.isActive = true
		} else {
			buttonWidthConstraint?.constant = useWidth
		}

		let baseHeight = mapLocationPoint.height
		let useHeight = max(minSize.height / max(useZoomScale, 1.0), baseHeight)
		if buttonHeightConstraint == nil {
			buttonHeightConstraint = heightAnchor.constraint(equalToConstant: useHeight)
			buttonHeightConstraint?.isActive = true
		} else {
			buttonHeightConstraint?.constant = useHeight
		}

		if isShowPin {
			if mapLocationPoint.radius != nil {
				// don't scale the visible button size - keep original map-scaled size
				let diameter = max(minVisibleSize.width, mapLocationPoint.width)
				visibleWidthConstraint?.constant = diameter
				visibleHeightConstraint?.constant = diameter
				visibleView?.layer.cornerRadius = diameter / 2
				buttonWidthConstraint?.constant = max(useWidth, diameter)
				buttonHeightConstraint?.constant = max(useHeight, diameter)
			} else {
				visibleWidthConstraint?.constant = bounds.width
				visibleHeightConstraint?.constant = bounds.height
			}
		}
        layoutIfNeeded()
	}

	private func addVisibleView() {
		if visibleView == nil, let button = self.button {
			let visibleView = UIView()
			button.addSubview(visibleView)
			visibleView.frame = bounds
			visibleView.translatesAutoresizingMaskIntoConstraints = false
			visibleView.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
			visibleView.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
			visibleWidthConstraint = visibleView.widthAnchor.constraint(equalToConstant: bounds.width)
			visibleWidthConstraint?.isActive = true
			visibleHeightConstraint = visibleView.heightAnchor.constraint(equalToConstant: bounds.height)
			visibleHeightConstraint?.isActive = true
			self.visibleView = visibleView
		}
		visibleView?.layer.backgroundColor = pinColor.cgColor
		visibleView?.isHidden = false
		size()
	}

	/// Some buttons have a marker on the map already - others need an explicit bg color to show them.
	private func setVisible() {
		if isShowPin && visibleView == nil {
			addVisibleView()
		} else if !isShowPin && visibleView != nil {
			visibleView?.isHidden = true
		}
	}
}

extension MapLocationButtonNib {

	public class func loadNib(key: MapLocationPointKey) -> MapLocationButtonNib? {
		let bundle = Bundle(for: MapLocationButtonNib.self)
		if let view = bundle.loadNibNamed("MapLocationButtonNib", owner: self, options: nil)?.first as? MapLocationButtonNib {
			view.button?.key = key
			return view
		}
		return nil
	}
}
