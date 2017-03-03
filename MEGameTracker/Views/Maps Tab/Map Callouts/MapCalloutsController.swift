//
//  MapCalloutsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/9/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class MapCalloutsController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView?
    
    // Calloutsable
    @IBOutlet weak var calloutsView: CalloutsView?
    public var callouts: [MapLocationable] = [] // set by tab group controller
    public weak var viewController: UIViewController? { return tabGroupController }
    
    public var inMap: Map? { return map }
    public weak var tabGroupController: MapCalloutsGroupsController? // set by tab group controller
    
    public var estimatedHeight: CGFloat { return calloutsView?.estimatedHeight ?? 0 }
    public var isDontScroll: Bool { return tabGroupController?.isDontScroll ?? false }
    public var shouldSegueToCallout: Bool { return tabGroupController?.shouldSegueToCallout ?? false }
    public var navigationPushController: UINavigationController? { return tabGroupController?.navigationPushController }
    
    public var map: Map? {
        return tabGroupController?.map
    }
    public var mapLocation: MapLocationable? {
        return tabGroupController?.mapLocation
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if isDontScroll {
            scrollView?.isScrollEnabled = false
            scrollView?.bounces = false
        }
        setupCallouts()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let mapLocation = self.mapLocation {
            calloutsView?.highlight(mapLocation: mapLocation)
        }
    }
    
    public func reloadRows(_ rows: [IndexPath]) {
        calloutsView?.reloadRows(rows)
    }
}

extension MapCalloutsController: Calloutsable {
//    public var callouts: [MapLocationable]
//    public var viewController: UIViewController?
    func setupCallouts(isForceReloadData: Bool = false) {
        DispatchQueue.main.async {
            self.calloutsView?.shouldSegueToCallout = self.shouldSegueToCallout
            self.calloutsView?.controller = self
            self.calloutsView?.nib?.tableView?.onLayout = { [weak self] in
                self?.calloutsView?.nib?.tableView?.constrainTableHeight()
                (self?.viewController as? MapCalloutsGroupsController)?.resetHeights()
            }
            self.calloutsView?.nib?.tableView?.isScrollEnabled = false
            self.calloutsView?.nib?.tableView?.bounces = false
            if isForceReloadData {
                self.calloutsView?.nib?.tableView?.reloadData()
            }
        }
    }
}

extension MapCalloutsController: Spinnerable {}
