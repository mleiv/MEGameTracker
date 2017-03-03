//
//  MapSplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class MapSplitViewController: UIViewController, MESplitViewController, Spinnerable {

    @IBOutlet public weak var mainPlaceholder: IBIncludedSubThing?
    @IBOutlet public weak var detailBorderLeftView: UIView?
    @IBOutlet public weak var detailPlaceholder: IBIncludedSubThing?
    public var ferriedSegue: FerriedPrepareForSegueClosure?
    public var dontSplitViewInPage = false
    
    @IBAction public func closeDetailStoryboard(_ sender: AnyObject?) {
        closeDetailStoryboard()
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ferriedSegue?(segue.destination)
    }
    
    // extra stuff just for split view map:
    
    @IBOutlet weak var mapPlaceholder: IBIncludedSubThing!
    
    public var map: Map? // set by segue
    public var mapLocation: MapLocationable? // set by segue
    
    // OriginHintable
    public var referringOriginHint: String?
    
    public var segueMap: Map? { // going to set by segue
        // TODO: fix this - this is a bad didSet
        didSet {
            ferriedSegue = { [weak self] (destinationController: UIViewController) in
                destinationController.find(controllerType: MapSplitViewController.self) {
                    (controller: MapSplitViewController) in
                    controller.map = self?.segueMap
                    controller.mapLocation = self?.segueMapLocationable
                }
            }
        }
    }
    public var segueMapLocationable: MapLocationable?
    
//    public var deepLinkedMap: Map?
    public var deepLinkedMapLocationable: MapLocationable?
    
    override public func performSegue(withIdentifier identifier: String, sender: Any?) {
        parent?.performSegue(withIdentifier: identifier, sender: sender)
    }
    
    lazy var ferriedSegueForCallouts: FerriedPrepareForSegueClosure = {
        // just return the current map, because callouts shares data with this page (and map controller)
        let closure: FerriedPrepareForSegueClosure = { [weak self] (destinationController: UIViewController) in
                destinationController.find(controllerType: MapCalloutsGroupsController.self) {
                (controller: MapCalloutsGroupsController) in
                controller.map = self?.map
                controller.mapLocation = self?.mapLocation
                controller.navigationPushController = self?.navigationController
            }
        }
        return closure
    }()
    
    // And because maps are fancy, we swap H/V orientation:
    
    @IBOutlet weak var splitViewStack: UIStackView!
    @IBOutlet weak var detailBorderLeftViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailBorderLeftViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailPlaceholderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailPlaceholderWidthConstraint: NSLayoutConstraint!
    
    var isCalloutsOpen = false

    public func openDetailStoryboard(_ storyboard: String, sceneId: String?) {
        if currentOrientation() == .landscape {
            splitViewStack.axis = .horizontal
            (detailBorderLeftView as? HairlineBorderView)?.reset(top: false, bottom: false, left: true, right: false)
            detailBorderLeftViewHeightConstraint.isActive = false
            detailBorderLeftViewWidthConstraint.isActive = true
            detailPlaceholderHeightConstraint.isActive = false
            detailPlaceholderWidthConstraint.isActive = true
        } else {
            splitViewStack.axis = .vertical
            (detailBorderLeftView as? HairlineBorderView)?.reset(top: true, bottom: false, left: false, right: false)
            detailBorderLeftViewHeightConstraint.isActive = true
            detailBorderLeftViewWidthConstraint.isActive = false
            detailPlaceholderHeightConstraint.isActive = true
            detailPlaceholderWidthConstraint.isActive = false
        }
        isCalloutsOpen = true
        internalOpenDetailStoryboard(storyboard, sceneId: sceneId)
    }
    public func closeDetailStoryboard() {
        internalCloseDetailStoryboard()
        isCalloutsOpen = false
    }

    enum SimpleOrientation { case portrait, landscape }
    
    func currentOrientation() -> SimpleOrientation {
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight {
            return .landscape
        } else {
            return .portrait
        }
    }

    // MARK: Rotation handling
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard isCalloutsOpen == true &&
              traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular
        else {
            super.viewWillTransition(to: size, with: coordinator)
            return
        }
        closeDetailStoryboard()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
//    //MARK: DeepLinkable protocol
//
//    override public func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        if let mapLocation = self.mapLocation {
//            showMapLocationable(mapLocation)
//        }
//        isPageLoaded = true
//    }
//    
//    public var isPageLoaded = false
//    
//    public func deepLink(object: DeepLinkingObject, type: String? = nil) {
//        // first, verify is acceptable object:
//        if let mapLocation = object as? MapLocationable {
//            // second, make sure page is done loading:
//            if isPageLoaded {
//                showMapLocationable(mapLocation)
//            } else {
//                deepLinkedMapLocationable = mapLocation
//            }
//        }
//    }
//    
//    func showMapLocationable(mapLocation: MapLocationable) {
//        startSpinner(inView: view)
//        (mainPlaceholder?.includedController as? MapController)?.deepLink(mapLocation)
//        stopSpinner(inView: view)
//        // finally, clear out value so it isn't called again:
//        deepLinkedMapLocationable = nil
//    }
}
