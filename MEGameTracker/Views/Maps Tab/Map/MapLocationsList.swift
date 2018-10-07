//
//  MapLocationsList.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/15/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public struct MapLocationsList {

	public var inMapId: String?
	public var inView: UIView?
	public var isSplitMenu: Bool = false // if the map is really a menu to other maps
	public var baseZoomScale: CGFloat = 1.0
//	public var onClick: ((MapLocationButtonNib) -> Void) = { _ in }
	var locations: [MapLocationPointKey: [MapLocationable]] = [:]
	var buttons: [MapLocationPointKey: MapLocationButtonNib] = [:]

	var initialZoomScale: CGFloat?
	var startingZoomScaleAdjustment: CGFloat?
	let mapTitlesVisibleZoomScales: [UIUserInterfaceIdiom: CGFloat] = [.phone: CGFloat(2.0), .pad: CGFloat(1.1)]

//	public init(
//		inMapId: String?,
//		inView: UIView? = nil,
//		isSplitMenu: Bool = false,
//		onClick: @escaping ((MapLocationButton) -> Void) = { _ in }

//	) {
//		self.inMapId = inMapId
//		self.inView = inView
//		self.isSplitMenu = isSplitMenu
//		self.onClick = onClick
//	}

	public func insertAll(inView view: UIView) {
		for (_, button) in buttons {
			if button.superview == nil {
				view.addSubview(button)
			}
		}
		view.layoutIfNeeded()
	}

	public func insert(button: MapLocationButtonNib, inView view: UIView) {
		if button.superview == nil {
			view.addSubview(button)
		}
		view.layoutIfNeeded()
	}

	public func isFound(location: MapLocationable) -> Bool {
		guard let point = location.mapLocationPoint else { return false }
		return locations[point.key]?.contains(where: { $0.isEqual(location) }) ?? false
	}

	public func getButton(atPoint point: MapLocationPoint) -> MapLocationButtonNib? {
		return buttons[point.key]
	}

	public func getButtonTouched(gestureRecognizer: UITapGestureRecognizer) -> MapLocationButtonNib? {
		return buttons.values.filter {
			let point = gestureRecognizer.location(in: $0.button)
			return $0.button?.point(inside: point, with: nil) == true
		}.first
	}

	public func getLocations(atPoint point: MapLocationPoint) -> [MapLocationable] {
		return locations[point.key] ?? []
	}

	public func getLocations(fromButton button: MapLocationButtonNib) -> [MapLocationable] {
		guard let key = button.mapLocationPoint?.key else { return [] }
		return locations[key] ?? []
	}

	public mutating func add(locations: [MapLocationable]) -> Bool {
		var isAdded = true
		for location in locations {
			isAdded = add(location: location) && isAdded
		}
		return isAdded
	}

	public mutating func add(location: MapLocationable, isIgnoreAvailabilityRules: Bool = false) -> Bool {
		guard let key = location.mapLocationPoint?.key else { return false }
		guard isVisible(location: location, isIgnoreAvailabilityRules: isIgnoreAvailabilityRules) else {
			remove(location: location)
			return false
		}
		if locations[key] == nil {
			locations[key] = [location]
		} else {
			if let index = locations[key]?.index(where: { $0.isEqual(location) }) {
				locations[key]?[index] = location
			} else {
				locations[key]?.append(location)
				locations[key] = locations[key]?.sorted(by: MapLocation.sort)
			}
		}
		addButton(atKey: key)
		return true
	}

	public mutating func removeAll() {
		for (_, button) in buttons {
			button.removeFromSuperview()
		}
		locations = [:]
		buttons = [:]
	}

	public mutating func remove(location: MapLocationable) {
		guard let point = location.mapLocationPoint else { return }
		if let index = locations[point.key]?.index(where: { $0.isEqual(location) }) {
			locations[point.key]?.remove(at: index)
			if locations[point.key]?.isEmpty == true {
				removeButton(atKey: point.key)
			}
		}
	}

	mutating func addButton(atKey key: MapLocationPointKey) {
		guard let location = locations[key]?[0] else { return }
		if buttons[key] == nil, let button = MapLocationButtonNib.loadNib(key: key) {
			buttons[key] = button
		}

		if let button = buttons[key] { // (we can only do this because UIButton is reference type)
			let isShowPin = location.isShowPin && (location.inMapId == inMapId || location.shownInMapId == inMapId)
			button.set(location: location, isShowPin: isShowPin)
			if isSplitMenu {

				// move to zoom?

				(button.title as? IBStyledLabel)?.identifier = "Body.NormalColor"
				button.titleWidthConstraint?.isActive = false
			}

//			button.onClick = self.onClick

			if let locationGroup: [MapLocationable] = locations[key], locationGroup.count > 1 {
				button.mapLocationPoint = locationGroup.compactMap {
					$0.mapLocationPoint
				}.reduce(MapLocationPoint(x: 0, y: 0, radius: 0)) {
					$0.width > $1.width && $0.height > $1.height ? $0 : $1
				}
				button.isShowPin = locationGroup.reduce(false) {
					$0 || ($1.isShowPin && ($1.inMapId == inMapId || $1.shownInMapId == inMapId))
				}
			}
		}
	}

	mutating func removeButton(atKey key: MapLocationPointKey) {
		buttons[key]?.removeFromSuperview()
		buttons.removeValue(forKey: key)
	}

	func resizeButtons(fromSize: CGSize, toSize: CGSize) {
		for (key, _) in buttons {
			resizeButton(atKey: key, fromSize: fromSize, toSize: toSize)
		}
	}

	func resizeButton(atKey key: MapLocationPointKey, fromSize: CGSize, toSize: CGSize) {
		guard let button = buttons[key] else { return }
		if let sizedMapLocationPoint = button.mapLocationPoint?.fromSize(fromSize, toSize: toSize),
			button.sizedMapLocationPoint != sizedMapLocationPoint {
			buttons[key]?.sizedMapLocationPoint = sizedMapLocationPoint
			if button.superview != nil {
				buttons[key]?.size(isForce: true)
			}
		}
	}

	mutating func zoomButtons(zoomScale: CGFloat) {
		for (key, _) in buttons {
			zoomButton(atKey: key, zoomScale: zoomScale)
		}
	}

	mutating func zoomButton(atKey key: MapLocationPointKey, zoomScale: CGFloat) {
		buttons[key]?.zoomScale = zoomScale

		if isSplitMenu {
			buttons[key]?.title?.contentScaleFactor = zoomScale
		} else {
			let deviceKind = UIDevice.current.userInterfaceIdiom
			guard let visibleZoomScale = mapTitlesVisibleZoomScales[deviceKind] else { return }
			let isVisible = (zoomScale / baseZoomScale) > visibleZoomScale
			buttons[key]?.title?.isHidden = !isVisible
			buttons[key]?.title?.contentScaleFactor = zoomScale
			buttons[key]?.titleWidthConstraint?.constant = max(50, ((inView?.bounds.width ?? 500.0) / 5.0))
		}
	}

	func isVisible(location: MapLocationable, isIgnoreAvailabilityRules: Bool) -> Bool {
		if isFound(location: location) { // if we've already approved it, allow it
			return true
		}
		guard location.shownInMapId == inMapId || location.inMapId == inMapId else { return false }
		if isSplitMenu == true || isIgnoreAvailabilityRules {
			return true
		}
		if location.mapLocationPoint != nil && location is Map {
			return true
		}
		if (location as? Mission)?.isCompleted == false || (location as? Item)?.isAcquired == false {
			return location.isAvailable
		}
		return false
	}

}
