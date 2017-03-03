//
//  MapCalloutsBoxNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/24/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

// TODO: click outside callout dismisses it
// TODO: click on label calls onClick event
// TODO: onClick event loads Map or deep links to other page
@IBDesignable final public class MapCalloutsBoxNib: UIView {

    public enum ArrowDirection { case top, bottom, right, left }
    
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
    var preferredArrowDirections: [ArrowDirection] = [.top, .bottom, .right, .left]
    var arrowDirection: ArrowDirection = .top
    var arrowBaseWidth = CGFloat(10)
    var arrowLength = CGFloat(20.0)
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
        paddingTopConstraint?.constant = arrowLength
        paddingBottomConstraint?.constant = arrowLength
        paddingLeftConstraint?.constant = arrowLength
        paddingRightConstraint?.constant = arrowLength
        constraintX?.isActive = false
        constraintY?.isActive = false
    }
    
    
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
        let missionIds: [String] = mapLocations.flatMap { ($0 as? Mission)?.id }
        var mapLocations = mapLocations.sorted(by: MapCalloutsBoxNib.sort).filter { !missionIds.contains($0.inMissionId ?? "") || (explicitCallout?.isEqual($0) ?? false) }
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
        guard let borderWrapper = self.borderWrapper else { return }
        
        // shift box to correct position
        selectDirection()
        moveCalloutBox()
        
        // draw container
        let borderLayer = CAShapeLayer()
        let maskLayer = CAShapeLayer()
        let borderWidth = calloutStrokeWidth
        let arrowBaseInnerWidth = arrowBaseWidth - (borderWidth * 2)
        let bounds = borderWrapper.bounds
        borderLayer.frame = bounds
        maskLayer.frame = bounds
        
        // now offset for arrow (otherwise its border color gets clipped off)
        borderLayer.frame.origin.x = borderWrapper.frame.origin.x
        borderLayer.frame.origin.y = borderWrapper.frame.origin.y
        maskLayer.frame.origin.x = borderWrapper.frame.origin.x
        maskLayer.frame.origin.y = borderWrapper.frame.origin.y
        
        let pathOuter = UIBezierPath()
        let pathInner = UIBezierPath()
        pathOuter.move(to: CGPoint(x: cornerRadius, y: 0))
        pathInner.move(to: CGPoint(x: cornerRadius + borderWidth, y: 0 + borderWidth))
        if arrowDirection == .top {
            var lineBreak = CGPoint(x: (bounds.width - arrowBaseWidth) / 2, y: 0)
            var lineBreakInner = CGPoint(x: (bounds.width - arrowBaseInnerWidth) / 2, y: 0 + borderWidth)
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
            let arrowPoint = CGPoint(x: bounds.width / 2, y: 0 - arrowLength)
            let arrowPointInner = CGPoint(x: arrowPoint.x, y: arrowPoint.y + (borderWidth * 2))
            pathOuter.addLine(to: arrowPoint)
            pathInner.addLine(to: arrowPointInner)
            lineBreak.x += arrowBaseWidth
            lineBreakInner.x += arrowBaseInnerWidth
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
        }
        let topRight = CGPoint(x: bounds.width, y: 0)
        let topRight1 = CGPoint(x: bounds.width - cornerRadius, y: 0)
        let topRight2 = CGPoint(x: bounds.width, y: cornerRadius)
        let topRightInner = CGPoint(x: bounds.width - (borderWidth / 2), y: 0 + (borderWidth / 2))
        let topRightInner1 = CGPoint(x: (bounds.width - cornerRadius) - borderWidth, y: 0 + borderWidth)
        let topRightInner2 = CGPoint(x: bounds.width - borderWidth, y: cornerRadius + borderWidth)
        pathOuter.addLine(to: topRight1)
        pathInner.addLine(to: topRightInner1)
        pathOuter.addQuadCurve(to: topRight2, controlPoint: topRight)
        pathInner.addQuadCurve(to: topRightInner2, controlPoint: topRightInner)
        if arrowDirection == .right {
            var lineBreak = CGPoint(x: bounds.width, y: (bounds.height - arrowBaseWidth) / 2)
            var lineBreakInner = CGPoint(x: bounds.width - borderWidth, y: (bounds.height - arrowBaseInnerWidth) / 2)
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
            let arrowPoint = CGPoint(x: bounds.width + arrowLength, y: bounds.height / 2)
            let arrowPointInner = CGPoint(x: arrowPoint.x - (borderWidth * 2), y: arrowPoint.y)
            pathOuter.addLine(to: arrowPoint)
            pathInner.addLine(to: arrowPointInner)
            lineBreak.y += arrowBaseWidth
            lineBreakInner.y += arrowBaseInnerWidth
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
        }
        let bottomRight = CGPoint(x: bounds.width, y: bounds.height)
        let bottomRight1 = CGPoint(x: bounds.width, y: bounds.height - cornerRadius)
        let bottomRight2 = CGPoint(x: bounds.width - cornerRadius, y: bounds.height)
        let bottomRightInner = CGPoint(x: bounds.width - (borderWidth / 2), y: bounds.height - (borderWidth / 2))
        let bottomRightInner1 = CGPoint(x: bounds.width - borderWidth, y: bounds.height - cornerRadius - borderWidth)
        let bottomRightInner2 = CGPoint(x: bounds.width - cornerRadius - borderWidth, y: bounds.height - borderWidth)
        pathOuter.addLine(to: bottomRight1)
        pathInner.addLine(to: bottomRightInner1)
        pathOuter.addQuadCurve(to: bottomRight2, controlPoint: bottomRight)
        pathInner.addQuadCurve(to: bottomRightInner2, controlPoint: bottomRightInner)
        if arrowDirection == .bottom {
            var lineBreak = CGPoint(x: ((bounds.width - arrowBaseWidth) / 2) + arrowBaseWidth, y: bounds.height)
            var lineBreakInner = CGPoint(x: ((bounds.width - arrowBaseInnerWidth) / 2) + arrowBaseInnerWidth, y: bounds.height - borderWidth)
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
            let arrowPoint = CGPoint(x: bounds.width / 2, y: bounds.height + arrowLength)
            let arrowPointInner = CGPoint(x: arrowPoint.x, y: arrowPoint.y - (borderWidth * 2))
            pathOuter.addLine(to: arrowPoint)
            pathInner.addLine(to: arrowPointInner)
            lineBreak.x -= arrowBaseWidth
            lineBreakInner.x -= arrowBaseInnerWidth
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
        }
        let bottomLeft = CGPoint(x: 0, y: bounds.height)
        let bottomLeft1 = CGPoint(x: cornerRadius, y: bounds.height)
        let bottomLeft2 = CGPoint(x: 0, y: bounds.height - cornerRadius)
        let bottomLeftInner = CGPoint(x: 0 + (borderWidth / 2), y: bounds.height - (borderWidth / 2))
        let bottomLeftInner1 = CGPoint(x: cornerRadius + borderWidth, y: bounds.height - borderWidth)
        let bottomLeftInner2 = CGPoint(x: 0 + borderWidth, y: bounds.height - cornerRadius - borderWidth)
        pathOuter.addLine(to: bottomLeft1)
        pathInner.addLine(to: bottomLeftInner1)
        pathOuter.addQuadCurve(to: bottomLeft2, controlPoint: bottomLeft)
        pathInner.addQuadCurve(to: bottomLeftInner2, controlPoint: bottomLeftInner)
        if arrowDirection == .left {
            var lineBreak = CGPoint(x: 0, y: ((bounds.height - arrowBaseWidth) / 2) + arrowBaseWidth)
            var lineBreakInner = CGPoint(x: 0 + borderWidth, y: ((bounds.height - arrowBaseInnerWidth) / 2) + arrowBaseInnerWidth)
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
            let arrowPoint = CGPoint(x: 0 - arrowLength, y: bounds.height / 2)
            let arrowPointInner = CGPoint(x: arrowPoint.x + (borderWidth * 2), y: arrowPoint.y)
            pathOuter.addLine(to: arrowPoint)
            pathInner.addLine(to: arrowPointInner)
            lineBreak.y -= arrowBaseWidth
            lineBreakInner.y -= arrowBaseInnerWidth
            pathOuter.addLine(to: lineBreak)
            pathInner.addLine(to: lineBreakInner)
        }
        let topLeft = CGPoint(x: 0, y: 0)
        let topLeft1 = CGPoint(x: 0, y: cornerRadius)
        let topLeft2 = CGPoint(x: cornerRadius, y: 0)
        let topLeftInner = CGPoint(x: 0 + (borderWidth / 2), y: 0 + (borderWidth / 2))
        let topLeftInner1 = CGPoint(x: 0 + borderWidth, y: cornerRadius + borderWidth)
        let topLeftInner2 = CGPoint(x: cornerRadius + borderWidth, y: 0 + borderWidth)
        pathOuter.addLine(to: topLeft1)
        pathInner.addLine(to: topLeftInner1)
        pathOuter.addQuadCurve(to: topLeft2, controlPoint: topLeft)
        pathInner.addQuadCurve(to: topLeftInner2, controlPoint: topLeftInner)
        pathOuter.close()
        pathInner.close()
        
        borderLayer.path = pathInner.cgPath
        outlineWrapper?.layer.backgroundColor = calloutBackgroundColor.cgColor
        outlineWrapper?.layer.mask = borderLayer
        
        maskLayer.path = pathOuter.cgPath
        layer.backgroundColor = calloutStrokeColor.cgColor
        layer.mask = maskLayer
    }
    
    func selectDirection() {
        guard let visibleFrame = visibleFrame(),
              let calloutOrigin = calloutOrigin,
              let calloutBounds = sizeWrapper?.bounds
        else {
            return
        }
        
        let centerCalloutOriginX = zoomScale * (calloutOrigin.sizedMapLocationPoint?.x ?? 0.0)
        let centerCalloutOriginY = zoomScale * (calloutOrigin.sizedMapLocationPoint?.y ?? 0.0)
        
//        let centerCalloutOriginX = zoomScale * (calloutOrigin.frame.origin.x + (calloutOrigin.bounds.width / 2))
//        let centerCalloutOriginY = zoomScale * (calloutOrigin.frame.origin.y + (calloutOrigin.bounds.height / 2))
        
        let visibleFrameTop = visibleFrame.origin.y
        let visibleFrameBottom = visibleFrame.origin.y + visibleFrame.size.height
        let visibleFrameLeft = visibleFrame.origin.x
        let visibleFrameRight = visibleFrame.origin.x + visibleFrame.size.width
        for direction in preferredArrowDirections {
            var stop = false
            switch direction {
            case .top:
                let boundaryBottom = centerCalloutOriginY + (calloutBounds.height + arrowLength)
                let boundaryLeft = centerCalloutOriginX - (calloutBounds.width / 2)
                let boundaryRight = centerCalloutOriginX + (calloutBounds.width / 2)
                if boundaryBottom < visibleFrameBottom && boundaryLeft > visibleFrameLeft && boundaryRight < visibleFrameRight {
                    arrowDirection = direction
                    stop = true
                }
            case .bottom: 
                let boundaryTop = centerCalloutOriginY - (calloutBounds.height + arrowLength)
                let boundaryLeft = centerCalloutOriginX - (calloutBounds.width / 2)
                let boundaryRight = centerCalloutOriginX + (calloutBounds.width / 2)
                if boundaryTop > visibleFrameTop && boundaryLeft > visibleFrameLeft && boundaryRight < visibleFrameRight {
                    arrowDirection = direction
                    stop = true
                }
            case .left: 
                let boundaryTop = centerCalloutOriginY - (calloutBounds.height / 2)
                let boundaryBottom = centerCalloutOriginY + (calloutBounds.height / 2)
                let boundaryRight = centerCalloutOriginX + (calloutBounds.width) + arrowLength
                if boundaryTop > visibleFrameTop && boundaryBottom < visibleFrameBottom && boundaryRight < visibleFrameRight {
                    arrowDirection = direction
                    stop = true
                }
            case .right:
                let boundaryTop = centerCalloutOriginY - (calloutBounds.height / 2)
                let boundaryBottom = centerCalloutOriginY + (calloutBounds.height / 2)
                let boundaryLeft = centerCalloutOriginX - (calloutBounds.width) + arrowLength
                    if boundaryTop > visibleFrameTop && boundaryBottom < visibleFrameBottom && boundaryLeft > visibleFrameLeft {
                    arrowDirection = direction
                    stop = true
                }
            }
            if stop {
                break
            }
        }
        // redo constraints and layout to match new arrow padding
        paddingTopConstraint?.constant = arrowDirection == .top ? arrowLength : 0.0
        paddingBottomConstraint?.constant = arrowDirection == .bottom ? arrowLength : 0.0
        paddingLeftConstraint?.constant = arrowDirection == .left ? arrowLength : 0.0
        paddingRightConstraint?.constant = arrowDirection == .right ? arrowLength : 0.0
        setNeedsLayout()
        layoutIfNeeded()
        borderWrapper?.frame.size = calloutBounds.size
    }
    
    func visibleFrame() -> CGRect? {
        guard let superview = self.superview
        else {
            return nil
        }
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
        
        let centerCalloutOriginX = zoomScale * (calloutOrigin.sizedMapLocationPoint?.x ?? 0.0)
        let centerCalloutOriginY = zoomScale * (calloutOrigin.sizedMapLocationPoint?.y ?? 0.0)
        
//        let centerCalloutOriginX = zoomScale * (calloutOrigin.frame.origin.x + (calloutOrigin.bounds.width / 2))
//        let centerCalloutOriginY = zoomScale * (calloutOrigin.frame.origin.y + (calloutOrigin.bounds.height / 2))

        switch arrowDirection {
        case .top:
            targetX = centerCalloutOriginX - (bounds.width / 2)
            targetY = centerCalloutOriginY
        case .bottom:
            targetX = centerCalloutOriginX - (bounds.width / 2)
            targetY = (centerCalloutOriginY - bounds.height)
        case .left:
            targetX = centerCalloutOriginX
            targetY = centerCalloutOriginY - (bounds.height / 2)
        case .right:
            targetX = (centerCalloutOriginX - bounds.width)
            targetY = centerCalloutOriginY - (bounds.height / 2)
        }
        constraintX?.constant = targetX
        constraintY?.constant = targetY
//        print("X \(targetX) Y \(targetY) ZOOMSCALE \(zoomScale) CALLOUT \(calloutOrigin.frame)")
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
//    public var callouts: [MapLocationable]
//    public var viewController: UIViewController?
}


extension MapCalloutsBoxNib {
    static let typeSortOrder: [MapLocationType] = [.map, .mission, .item]
    static func sort(_ a: MapLocationable, b: MapLocationable) -> Bool {
        if let typeA = typeSortOrder.index(of: a.mapLocationType), let typeB = typeSortOrder.index(of: b.mapLocationType)
            , typeA != typeB {
            return typeA < typeB
        } else if let aMission = a as? Mission, let bMission = b as? Mission {
            return Mission.sort(aMission, b: bMission)
        } else if let aMap = a as? Map, let bMap = b as? Map {
            return Map.sort(aMap, b: bMap)
        } else if let aItem = a as? Item, let bItem = b as? Item {
            return Item.sort(aItem, b: bItem)
        } else {
            return false
        }
    }
}
