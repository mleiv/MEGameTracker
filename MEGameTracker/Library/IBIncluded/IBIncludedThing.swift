////
////  IBIncludedThing.swift
////
////  Copyright 2016 Emily Ivie
//
////  Licensed under The MIT License
////  For full copyright and license information, please see http://opensource.org/licenses/MIT
////  Redistributions of files must retain the above copyright notice.


import UIKit

/// Allows for removing individual scene design from the flow storyboards and into individual per-controller storyboards, which minimizes git merge conflicts.
// *NOT* @IBDesignable - we only use preview for IB preview
open class IBIncludedThing: UIViewController, IBIncludedThingLoadable {

    @IBInspectable
    open var incStoryboard: String? // abbreviated for shorter label in IB
    open var includedStoryboard: String? {
        get { return incStoryboard }
        set { incStoryboard = newValue }
    }
    @IBInspectable
    open var sceneId: String?
    @IBInspectable
    open var incNib: String? // abbreviated for shorter label in IB
    open var includedNib: String? {
        get { return incNib }
        set { incNib = newValue }
    }
    @IBInspectable
    open var nibController: String?
    
    /// The controller loaded during including the above storyboard or nib
    open weak var includedController: UIViewController?
    
    /// Typical initialization of IBIncludedThing when it is created during normal scene loading at run time.
    open override func awakeFromNib() {
        super.awakeFromNib()
        attach(toController: self, toView: nil)
    }
    
    open override func loadView() {
        super.loadView()
        attach(toController: nil, toView: self.view)
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        includedController?.prepare(for: segue, sender: sender)
        // The following code will run prepareForSegue in all child view controllers. 
        // This can cause unexpected multiple calls to prepareForSegue, so I prefer to be more cautious about which view controllers invoke prepareForSegue.
        // See IBIncludedThingDemo FourthController and SixthController for examples and options with embedded view controllers.
//        includedController?.findType(UIViewController.self) { controller in
//            controller.prepareForSegue(segue, sender: sender)
//        }
    }
}



/// Because UIViewController does not preview in Interface Builder, this is an Interface-Builder-only companion to IBIncludedThing. Typically you would set the scene owner to IBIncludedThing and then set the top-level view to IBIncludedThingPreview, with identical IBInspectable values.
@IBDesignable
open class IBIncludedThingPreview: UIView, IBIncludedThingLoadable {

    @IBInspectable
    open var incStoryboard: String? // abbreviated for shorter label in IB
    open var includedStoryboard: String? {
        get { return incStoryboard }
        set { incStoryboard = newValue }
    }
    @IBInspectable
    open var sceneId: String?
    @IBInspectable
    open var incNib: String? // abbreviated for shorter label in IB
    open var includedNib: String? {
        get { return incNib }
        set { incNib = newValue }
    }
    @IBInspectable
    open var nibController: String?

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        attach(toController: nil, toView: self)
    }
    
    // protocol conformance only (does not use):
    open weak var includedController: UIViewController?
}


/// Can be used identically to IBIncludedThing, but for subviews inside scenes rather than an entire scene. The major difference is that IBIncludedSubThing views, unfortunately, cannot be configured using prepareForSegue, because they are loaded too late in the view controller lifecycle.
@IBDesignable
open class IBIncludedSubThing: UIView, IBIncludedThingLoadable {

    @IBInspectable
    open var incStoryboard: String? // abbreviated for shorter label in IB
    open var includedStoryboard: String? {
        get { return incStoryboard }
        set { incStoryboard = newValue }
    }
    @IBInspectable
    open var sceneId: String?
    @IBInspectable
    open var incNib: String? // abbreviated for shorter label in IB
    open var includedNib: String? {
        get { return incNib }
        set { incNib = newValue }
    }
    @IBInspectable
    open var nibController: String?
    
    /// The controller loaded during including the above storyboard or nib
    open weak var includedController: UIViewController?
    
    /// An optional parent controller to use when this is being instantiated in code (and so might not have a hierarchy).
    /// This would be private, but the protocol needs it.
    open weak var parentController: UIViewController?
    
//    /// Convenience initializer for programmatic inclusion
//    public init?(incStoryboard: String? = nil, sceneId: String? = nil, incNib: String? = nil, nibController: String? = nil, intoView parentView: UIView? = nil, intoController parentController: UIViewController? = nil) {
//        self.incStoryboard = incStoryboard
//        self.sceneId = sceneId
//        self.incNib = incNib
//        self.nibController = nibController
//        self.parentController = parentController
//        super.init(frame: CGRectZero)
//        guard incStoryboard != nil || incNib != nil else {
//            return nil
//        }
//        // then also pin this IBIncludedSubThing to a parent view if so requested:
//        if let view = parentView ?? parentController?.view {
//            attach(incView: self, toView: view)
//        }
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    /// Initializes the IBIncludedSubThing for preview inside Xcode.
    /// Does not bother attaching view controller to hierarchy.
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        attach(toController: nil, toView: self)
    }

    /// Typical initialization of IBIncludedSubThing when it is created during normal scene loading at run time.
    open override func awakeFromNib() {
        super.awakeFromNib()
        if parentController == nil {
            parentController = findParent(ofController: activeController(under: topController()))
        }
        attach(toController: parentController, toView: self)
    }
    
    // And then we need all these to get parent controller:
    
    /// Grabs access to view controller hierarchy if possible.
    fileprivate func topController() -> UIViewController? {
        if let controller = window?.rootViewController {
            return controller
        } else if let controller = UIApplication.shared.keyWindow?.rootViewController {
            return controller
        }
        return nil
    }
    
    /// Locates the top-most currently visible controller.
    fileprivate func activeController(under controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else {
            return nil
        }
        if let tabController = controller as? UITabBarController, let nextController = tabController.selectedViewController {
            return activeController(under: nextController)
        } else if let navController = controller as? UINavigationController, let nextController = navController.visibleViewController {
            return activeController(under: nextController)
        } else if let nextController = controller.presentedViewController {
            return activeController(under: nextController)
        }
        return controller
    }
    
    /// Locates the view controller with this view inside of it (depth first, since in a hierarchy of view controllers the view would likely be in all the parentViewControllers of its view controller).
    fileprivate func findParent(ofController topController: UIViewController!) -> UIViewController? {
        if topController == nil {
            return nil
        }
        for viewController in topController.childViewControllers {
            // first try, deep dive into child controllers
            if let parentViewController = findParent(ofController: viewController) {
                return parentViewController
            }
        }
        // second try, top view controller (most generic, most things will be in this view)
        if let topView = topController?.view , findSelf(inView: topView) {
            return topController
        }
        return nil
    }

    /// Identifies if the IBIncludedSubThing view is equal to or under the view given.
    fileprivate func findSelf(inView topView: UIView) -> Bool {
        if topView == self || topView == self.superview {
            return true
        } else {
            for view in topView.subviews {
                if findSelf(inView: view ) {
                    return true
                }
            }
        }
        return false
    }
}


/// This holds all the shared functionality of the IBIncludedThing variants.
public protocol IBIncludedThingLoadable: class {
    // defining properties:
    var includedStoryboard: String? { get set }
    var sceneId: String? { get set }
    var includedNib: String? { get set }
    var nibController: String? { get set }
    // reference:
    weak var includedController: UIViewController? { get set }
    // main:
    func attach(toController parentController: UIViewController?, toView parentView: UIView?)
    func detach()
    // supporting:
    func getController(inBundle bundle: Bundle) -> UIViewController?
    func attach(controller: UIViewController?, toParent parentController: UIViewController?)
    func attach(view: UIView?, toView parentView: UIView)
    // useful:
    func reload(includedStoryboard: String, sceneId: String?)
    func reload(includedNib: String, nibController: String?)
}

extension IBIncludedThingLoadable {
    
    /// Main function to attach the included content.
    public func attach(toController parentController: UIViewController?, toView parentView: UIView?) {
        guard let includedController = includedController ?? getController(inBundle: Bundle(for: type(of: self))) else {
            return
        }
        if let parentController = parentController {
            attach(controller: includedController, toParent: parentController)
        }
        if let parentView = parentView {
            attach(view: includedController.view, toView: parentView)
        }
    }
    
    /// Main function to remove the included content.
    public func detach() {
        includedController?.view.removeFromSuperview()
        includedController?.removeFromParentViewController()
        self.includedStoryboard = nil
        self.sceneId = nil
        self.includedNib = nil
        self.nibController = nil
    }
    
    /// Internal: loads the controller from the storyboard or nib
    public func getController(inBundle bundle: Bundle) -> UIViewController? {
        var foundController: UIViewController?
        if let storyboardName = self.includedStoryboard {
            // load storyboard
            let storyboardObj = UIStoryboard(name: storyboardName, bundle: bundle)
            let sceneId = self.sceneId ?? ""
            foundController = sceneId.isEmpty ? storyboardObj.instantiateInitialViewController() : storyboardObj.instantiateViewController(withIdentifier: sceneId)
        } else if let nibName = self.includedNib {
            // load nib
            if let controllerName = nibController,
                let appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
                // load specified controller
                let classStringName = "\(appName).\(controllerName)"
                if let ControllerType = NSClassFromString(classStringName) as? UIViewController.Type {
                    foundController = ControllerType.init(nibName: nibName, bundle: bundle) as UIViewController
                }
            } else {
                // load generic controller
                foundController = UIViewController(nibName: nibName, bundle: bundle)
            }
        }
        return foundController
    }
    
    /// Internal: inserts the included controller into the view hierarchy (this helps trigger correct view hierarchy lifecycle functions)
    public func attach(controller: UIViewController?, toParent parentController: UIViewController?) {
        // save for later (do not explicitly reference view or you will trigger viewDidLoad)
        guard let controller = controller, let parentController = parentController else {
            return
        }
        // save for later use
        includedController = controller
        // attach to hierarchy
        controller.willMove(toParentViewController: parentController)
        parentController.addChildViewController(controller)
        controller.didMove(toParentViewController: parentController)
    }
    
    /// Internal: inserts the included view inside the IBIncludedThing view. Makes this nesting invisible by removing any background on IBIncludedThing and sets constraints so included content fills IBIncludedThing.
    public func attach(view: UIView?, toView parentView: UIView) {
        guard let view = view else {
            return
        }
        parentView.addSubview(view)
        
        //clear out top-level view visibility, so only subview shows
        parentView.isOpaque = false
        parentView.backgroundColor = UIColor.clear
        
        //tell child to fit itself to the edges of wrapper (self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
    }
    
    /// Programmatic reloading of a storyboard inside the same IBIncludedSubThing view.
    /// parentController is only necessary when the storyboard has had no previous storyboard, and so is missing an included controller (and its parent).
    public func reload(includedStoryboard: String, sceneId: String?) {
        let parentController = (self as? IBIncludedThing) ?? (self as? IBIncludedSubThing)?.parentController
        guard includedStoryboard != self.includedStoryboard || sceneId != self.sceneId,
            let parentView = (self as? IBIncludedSubThing) ?? parentController?.view else {
            return
        }
        // cleanup old stuff
        detach()
        self.includedController = nil
        // reset to new values
        self.includedStoryboard = includedStoryboard
        self.sceneId = sceneId
        self.includedNib = nil
        self.nibController = nil
        // reload
        attach(toController: parentController, toView: parentView)
    }
    
    /// Programmatic reloading of a nib inside the same IBIncludedSubThing view.
    /// parentController is only necessary when the storyboard has had no previous storyboard, and so is missing an included controller (and its parent).
    public func reload(includedNib: String, nibController: String?) {
        let parentController = (self as? IBIncludedThing) ?? (self as? IBIncludedSubThing)?.parentController
        guard includedNib != self.includedNib || nibController != self.nibController,
            let parentView = (self as? IBIncludedSubThing) ?? parentController?.view else {
            return
        }
        // cleanup old stuff
        detach()
        self.includedController = nil
        // reset to new values
        self.includedStoryboard = nil
        self.sceneId = nil
        self.includedNib = includedNib
        self.nibController = nibController
        // reload
        attach(toController: parentController, toView: parentView)
    }
    
}

extension UIViewController {
    
    /// A convenient utility for quickly running some code on a view controller of a specific type in the current view controller hierarchy.
    public func find<T: UIViewController>(controllerType: T.Type, apply: ((T) -> Void)) {
        for childController in childViewControllers {
            if let foundController = childController as? T {
                apply(foundController)
            } else {
                childController.find(controllerType: controllerType, apply: apply)
            }
        }
        if let foundController = self as? T {
            apply(foundController)
        }
    }
}

extension UIWindow {

    static var isInterfaceBuilder: Bool {
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }

}
