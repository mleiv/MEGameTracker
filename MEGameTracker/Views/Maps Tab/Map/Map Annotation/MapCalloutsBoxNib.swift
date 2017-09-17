//
//  MapCalloutsBoxNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/24/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable final public class MapCalloutsBoxNib: UIView {

	typealias BoxType = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

	@IBOutlet weak var outlineWrapper: UIView?
	@IBOutlet weak var borderWrapper: UIView?
		var borderLayer: CAShapeLayer?
		var defaultSize: CGSize?
		var constraintX: NSLayoutConstraint?
		var constraintY: NSLayoutConstraint?
	@IBOutlet weak var sizeWrapper: UIView?

	@IBOutlet weak var sizeMaxWidthConstraint: NSLayoutConstraint?
	@IBOutlet weak var sizeMinWidthConstraint: NSLayoutConstraint?
	@IBOutlet weak var sizeWidthConstraint: NSLayoutConstraint?

	@IBOutlet weak var paddingTopConstraint: NSLayoutConstraint?
	@IBOutlet weak var paddingBottomConstraint: NSLayoutConstraint?
	@IBOutlet weak var paddingLeftConstraint: NSLayoutConstraint?
	@IBOutlet weak var paddingRightConstraint: NSLayoutConstraint?

	@IBOutlet weak var footerWrapper: HairlineBorderView?
	@IBOutlet weak var footerLabel: IBStyledLabel?

	// Calloutsable
	@IBOutlet weak var calloutsView: CalloutsView?
	public var inMap: Map? { return calloutOriginController?.map }
	public var callouts: [MapLocationable] = []
	public var viewController: UIViewController? { return calloutOriginController }
	public var navigationPushController: UINavigationController? { return calloutOriginController?.navigationController }

	@IBAction func onClickFooter(_ sender: UIButton) {
		// TODO: add segue value to track whether to open callouts view on map immediately ?
		calloutsView?.select(mapLocation: mapLocations.first, sender: sender)
	}

	// set by calling controller
	public var mapLocations: [MapLocationable] = []
	public var explicitCallout: MapLocationable? // TODO: add to MapController, use in segue, pass here
	public weak var calloutOrigin: MapLocationButtonNib?
	public weak var calloutOriginController: MapController?
	public var zoomScale: CGFloat = 1.0

	// size
	var largestMaxWidth: CGFloat = 400.0
	var currentMaxWidth: CGFloat = 400.0

	// style
	var preferredTailDirections: [CalloutBalloon.TailDirection] = [.up, .down, .right, .left]
	var tailDirection: CalloutBalloon.TailDirection = .up
	var tailBaseWidth = CGFloat(10)
	var tailLength = CGFloat(20.0)
	var cornerRadius = CGFloat(10)
	var calloutStrokeWidth = CGFloat(1.0)
	var calloutStrokeColor = Styles.Colors.normalColor
	var calloutBackgroundColor = Styles.Colors.normalOppositeColor

	//footer
	let pendingMessage = "%d_missions more missions, %d_items more items"
	let totalCalloutsLimit = 4
	var filteredMissions: Int = 0
	var filteredItems: Int = 0

	public override func didMoveToSuperview() {
		guard superview != nil else { return }
		setup()
	}

	public func setup() {
		guard borderWrapper != nil else { return }

		reset()

		// save default for cleanup
		if defaultSize == nil {
			defaultSize = borderWrapper?.bounds.size
		}

		// setup starting size
		if let windowWidth = calloutOrigin?.superview?.superview?.bounds.width {
			currentMaxWidth = min(largestMaxWidth, windowWidth * 0.7)
			sizeMaxWidthConstraint?.constant = currentMaxWidth
			sizeWidthConstraint?.constant = currentMaxWidth
			calloutsView?.nib?.tableView?.frame.size.width = currentMaxWidth
		}

		// set up box size monitor
		calloutsView?.nib?.tableView?.onLayout = { [weak self] in
			self?.constrainHeight()
			self?.constrainWidth()
		}

		// setup data
		callouts = limitMapLocations(mapLocations)
		setupFooter()
		calloutsView?.controller = self

		// size loaded data
		calloutsView?.layoutIfNeeded()
		constrainHeight()
		constrainWidth()
		layoutIfNeeded()

		// reset superview placement constraint
		if constraintX == nil && constraintY == nil {
			constraintX = leftAnchor.constraint(equalTo: (superview?.leftAnchor)!)
			constraintY = topAnchor.constraint(equalTo: (superview?.topAnchor)!)
		}
		constraintX?.isActive = true
		constraintY?.isActive = true

		// draw the border
		setupBorderedBox()
	}

	func reset() {
		filteredMissions = 0
		filteredItems = 0
		if let size = defaultSize {
			borderWrapper?.bounds.size = size
		}
		paddingTopConstraint?.constant = tailLength
		paddingBottomConstraint?.constant = tailLength
		paddingLeftConstraint?.constant = tailLength
		paddingRightConstraint?.constant = tailLength
		constraintX?.isActive = false
		constraintY?.isActive = false
	}
}

extension MapCalloutsBoxNib {

	func constrainHeight() {
		calloutsView?.nib?.tableView?.constrainTableHeight()
	}
	func constrainWidth() {
		var width: CGFloat = 0.0
		if let estimatedWidth: CGFloat = calloutsView?.estimatedWidth {
			if footerWrapper?.isHidden == false,
				let footerLabel = self.footerLabel {
				let footerPadding: CGFloat = 30.0
				width = max(estimatedWidth, footerPadding + footerLabel.bounds.width)
			}
			width = estimatedWidth
		}

		let useWidth: CGFloat = width > 0 ? width : currentMaxWidth
		// prevent needless fiddling between tiny value changes (endless loop sometimes):
		guard abs(useWidth - (sizeWidthConstraint?.constant ?? 0.0)) > 5.0 else { return }
		sizeWidthConstraint?.constant = useWidth
	}

	func limitMapLocations(_ mapLocations: [MapLocationable]) -> [MapLocationable] {
		// filter out child missions/items in same location as parent
		// TODO: make an exception for specific callouts from segue!
		var ids: [String] = Array(Set( mapLocations.flatMap { $0.id }))
		var mapLocations = mapLocations.sorted(by: MapCalloutsBoxNib.sort).filter {
			!ids.contains($0.inMissionId ?? "") || (explicitCallout?.isEqual($0) ?? false)
		}
		mapLocations = mapLocations.flatMap {
			if let index = ids.index(of: $0.id) { ids.remove(at: index); return $0 }; return nil
		}
		guard mapLocations.first is Map else {
			return mapLocations
		}
		guard mapLocations.count > totalCalloutsLimit else {
			return mapLocations
		}
		let startMissionsCount = mapLocations.filter { $0 is Mission }.count
		let startItemsCount = mapLocations.filter { $0 is Item }.count
		var holdingPen: [MapLocationable] = []
		while mapLocations.count + holdingPen.count > totalCalloutsLimit && !(mapLocations.last is Map) {
			let row = mapLocations.removeLast()
			if row.id == explicitCallout?.id {
				holdingPen.insert(row, at: 0)
			}
		}
		mapLocations += holdingPen
		filteredMissions = startMissionsCount - mapLocations.filter { $0 is Mission }.count
		filteredItems = startItemsCount - mapLocations.filter { $0 is Item }.count
		return mapLocations
	}

	func setupFooter() {
		footerLabel?.text = pendingMessage.localize(filteredMissions, filteredItems)
		footerWrapper?.isHidden = footerLabel?.text?.isEmpty ?? true
	}

	func setupBorderedBox() {

		// shift box to correct position
		selectDirection()
		moveCalloutBox()

		var balloon = CalloutBalloon(
			baseLayer: layer,
			visibleWrapper: outlineWrapper,
			sizeWrapper: borderWrapper,
			tailDirection: tailDirection,
			tailLength: tailLength,
			tailWidth: tailBaseWidth,
			borderWidth: calloutStrokeWidth,
			cornerRadius: cornerRadius,
			borderColor: calloutStrokeColor,
			backgroundColor: calloutBackgroundColor
		)
		balloon.render()
	}

	func selectDirection() {
		guard let visibleFrame = visibleFrame(),
			  let calloutOrigin = calloutOrigin,
			  let calloutBounds = sizeWrapper?.bounds
		else {
			return
		}
		// scale to center point
		let centerCallout = CGPoint(
			x: zoomScale * (calloutOrigin.sizedMapLocationPoint?.x ?? 0.0),
			y: zoomScale * (calloutOrigin.sizedMapLocationPoint?.y ?? 0.0)
		)
		// easier-named visible area
		var visibleBox: BoxType = (top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		visibleBox.top = visibleFrame.origin.y
		visibleBox.left = visibleFrame.origin.x
		visibleBox.bottom = visibleFrame.origin.y + visibleFrame.size.height
		visibleBox.right = visibleFrame.origin.x + visibleFrame.size.width
		// now test each direction - order directions by order of precedent
		var stop = false
		for direction in preferredTailDirections {
			switch direction {
				case .up:
					if hasRoomForTailTop(visibleBox: visibleBox, centerCallout: centerCallout) {
						tailDirection = direction
						stop = true
					}
				case .down:
					if hasRoomForTailBottom(visibleBox: visibleBox, centerCallout: centerCallout) {
						tailDirection = direction
						stop = true
					}
				case .left:
					if hasRoomForTailLeft(visibleBox: visibleBox, centerCallout: centerCallout) {
						tailDirection = direction
						stop = true
					}
				case .right:
					if hasRoomForTailRight(visibleBox: visibleBox, centerCallout: centerCallout) {
						tailDirection = direction
						stop = true
					}
			}
			if stop { break }
		}
		// redo constraints and layout to match new arrow padding
		paddingTopConstraint?.constant = tailDirection == .up ? tailLength : 0.0
		paddingBottomConstraint?.constant = tailDirection == .down ? tailLength : 0.0
		paddingLeftConstraint?.constant = tailDirection == .left ? tailLength : 0.0
		paddingRightConstraint?.constant = tailDirection == .right ? tailLength : 0.0
		layoutIfNeeded()
		borderWrapper?.frame.size = calloutBounds.size
	}

	private func hasRoomForTailTop(visibleBox: BoxType, centerCallout: CGPoint) -> Bool {
		guard let calloutBounds = sizeWrapper?.bounds else { return false }
		let boundaryBottom = centerCallout.y + (calloutBounds.height + tailLength)
		let boundaryLeft = centerCallout.x - (calloutBounds.width / 2)
		let boundaryRight = centerCallout.x + (calloutBounds.width / 2)
		if boundaryBottom < visibleBox.bottom
			&& boundaryLeft > visibleBox.left && boundaryRight < visibleBox.right {
			return true
		}
		return false
	}

	private func hasRoomForTailLeft(visibleBox: BoxType, centerCallout: CGPoint) -> Bool {
		guard let calloutBounds = sizeWrapper?.bounds else { return false }
		let boundaryTop = centerCallout.y - (calloutBounds.height / 2)
		let boundaryBottom = centerCallout.y + (calloutBounds.height / 2)
		let boundaryRight = centerCallout.x + (calloutBounds.width) + tailLength
		if boundaryTop > visibleBox.top
			&& boundaryBottom < visibleBox.bottom && boundaryRight < visibleBox.right {
			return true
		}
		return false
	}

	private func hasRoomForTailBottom(visibleBox: BoxType, centerCallout: CGPoint) -> Bool {
		guard let calloutBounds = sizeWrapper?.bounds else { return false }
		let boundaryTop = centerCallout.y - (calloutBounds.height + tailLength)
		let boundaryLeft = centerCallout.x - (calloutBounds.width / 2)
		let boundaryRight = centerCallout.x + (calloutBounds.width / 2)
		if boundaryTop > visibleBox.top
			&& boundaryLeft > visibleBox.left && boundaryRight < visibleBox.right {
			return true
		}
		return false
	}

	private func hasRoomForTailRight(visibleBox: BoxType, centerCallout: CGPoint) -> Bool {
		guard let calloutBounds = sizeWrapper?.bounds else { return false }
		let boundaryTop = centerCallout.y - (calloutBounds.height / 2)
		let boundaryBottom = centerCallout.y + (calloutBounds.height / 2)
		let boundaryLeft = centerCallout.x - (calloutBounds.width) + tailLength
		if boundaryTop > visibleBox.top
			&& boundaryBottom < visibleBox.bottom && boundaryLeft > visibleBox.left {
			return true
		}
		return false
	}

	func visibleFrame() -> CGRect? {
		guard let superview = self.superview else { return nil }
		var findScrollView: UIView? = superview
		while findScrollView != nil && !(findScrollView is UIScrollView) {
			findScrollView = findScrollView?.superview
		}
		if let scrollView = findScrollView as? UIScrollView {
			var bounds = CGRect.zero
			bounds.origin.x = superview.frame.origin.x + scrollView.bounds.origin.x
			bounds.origin.y = superview.frame.origin.y + scrollView.bounds.origin.y
			bounds.size.width = scrollView.bounds.width
			bounds.size.height = scrollView.bounds.height
			return bounds
		}
		return superview.frame
	}

	public func moveCalloutBox() {
		guard let calloutOrigin = self.calloutOrigin else { return }
		var targetX = CGFloat(0.0)
		var targetY = CGFloat(0.0)

		let centerCallout = CGPoint(
			x: zoomScale * (calloutOrigin.sizedMapLocationPoint?.x ?? 0.0),
			y: zoomScale * (calloutOrigin.sizedMapLocationPoint?.y ?? 0.0)
		)

		switch tailDirection {
			case .up:
				targetX = centerCallout.x - (bounds.width / 2)
				targetY = centerCallout.y
			case .down:
				targetX = centerCallout.x - (bounds.width / 2)
				targetY = (centerCallout.y - bounds.height)
			case .left:
				targetX = centerCallout.x
				targetY = centerCallout.y - (bounds.height / 2)
			case .right:
				targetX = (centerCallout.x - bounds.width)
				targetY = centerCallout.y - (bounds.height / 2)
		}
		constraintX?.constant = targetX
		constraintY?.constant = targetY
//		print("X \(targetX) Y \(targetY) ZOOMSCALE \(zoomScale) CALLOUT \(calloutOrigin.frame)")
	}

	public class func loadNib() -> MapCalloutsBoxNib? {
		let bundle = Bundle(for: MapCalloutsBoxNib.self)
		if let view = bundle.loadNibNamed("MapCalloutsBoxNib", owner: self, options: nil)?.first as? MapCalloutsBoxNib {
			view.translatesAutoresizingMaskIntoConstraints = false
			return view
		}
		return nil
	}
}

extension MapCalloutsBoxNib: Calloutsable {
    public func updateCallouts(_ callouts: [MapLocationable]) {
        self.callouts = callouts
    }
}

extension MapCalloutsBoxNib {
	static let typeSortOrder: [MapLocationType] = [.map, .mission, .item]
	static func sort(_ first: MapLocationable, _ second: MapLocationable) -> Bool {
		if let firstType = typeSortOrder.index(of: first.mapLocationType),
			let secondType = typeSortOrder.index(of: second.mapLocationType),
			firstType != secondType {
			return firstType < secondType
		} else if let firstMission = first as? Mission, let secondMission = second as? Mission {
			return Mission.sort(firstMission, secondMission)
		} else if let firstMap = first as? Map, let secondMap = second as? Map {
			return Map.sort(firstMap, secondMap)
		} else if let firstItem = first as? Item, let secondItem = second as? Item {
			return Item.sort(firstItem, secondItem)
		} else {
			return false
		}
	}
}
