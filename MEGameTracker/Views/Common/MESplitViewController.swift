//
//  MESplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public typealias FerriedPrepareForSegueClosure = ((UIViewController) -> Void)

/// For device-specific segues: splits on Regular width, pushes on Compact width.
public protocol MESplitViewController: class {
    weak var mainPlaceholder: IBIncludedSubThing? { get } // required
    weak var detailBorderLeftView: UIView? { get } // required
    weak var detailPlaceholder: IBIncludedSubThing? { get } // required
    var ferriedSegue: FerriedPrepareForSegueClosure? { get set } // required
    var dontSplitViewInPage: Bool { get } // required
    func performChangeableSegue(_ identifier: String, sender: AnyObject!, ferriedSegue: @escaping FerriedPrepareForSegueClosure)
    func openDetailStoryboard(_ storyboard: String, sceneId: String?) 
        func internalOpenDetailStoryboard(_ storyboard: String, sceneId: String?)
    func closeDetailStoryboard(_ sender: AnyObject?) // required
        func closeDetailStoryboard()
        func internalCloseDetailStoryboard()
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

extension MESplitViewController where Self: UIViewController {

    /// Relies on consistent naming of segues and scenes in this pattern:
    /// - Segue: "Show {Storyboard}.{SceneId}"
    /// - NavigationController with Scene as root: "Nav-Wrapped {SceneId}"
    public func performChangeableSegue(_ identifier: String, sender: AnyObject!, ferriedSegue: @escaping FerriedPrepareForSegueClosure) {
        self.ferriedSegue = ferriedSegue
        if view.traitCollection.horizontalSizeClass == .compact || dontSplitViewInPage {
            parent?.performSegue(withIdentifier: identifier, sender: sender)
        } else {
            let parts = identifier.stringFrom(5).components(separatedBy: ".")
            if parts.count == 2 {
                openDetailStoryboard(parts[0], sceneId: "Nav-Wrapped \(parts[1])")
            }
        }
    }
    
    public func openDetailStoryboard(_ storyboard: String, sceneId: String?) {
        internalOpenDetailStoryboard(storyboard, sceneId: sceneId)
    }
    public func internalOpenDetailStoryboard(_ storyboard: String, sceneId: String?) {
        detailPlaceholder?.reload(includedStoryboard: storyboard, sceneId: sceneId)
        _ = (detailPlaceholder?.includedController as? UINavigationController)?.popToRootViewController(animated: false)
        if let controller = (detailPlaceholder?.includedController as? UINavigationController)?.visibleViewController {
            ferriedSegue?(controller)
            // attach close button
            let closeButton = MESplitViewControllerBarButtonItem(title: "Close", style: .done, actionHandler: { [weak self] in self?.closeDetailStoryboard() })
            controller.navigationItem.leftBarButtonItem = closeButton
            detailPlaceholder?.isHidden = false
            detailBorderLeftView?.isHidden = false
            view.layoutIfNeeded()
        }
    }
    
    public func closeDetailStoryboard() {
        internalCloseDetailStoryboard()
    }
    public func internalCloseDetailStoryboard() {
        detailPlaceholder?.detach()
        detailPlaceholder?.isHidden = true
        detailBorderLeftView?.isHidden = true
    }
    
}

final public class MESplitViewControllerBarButtonItem: UIBarButtonItem {
    // https://www.reddit.com/r/swift/comments/3fjzap/creating_button_action_programatically_using/
    var actionHandler: ((Void) -> Void)?
    public convenience init(title: String?, style: UIBarButtonItemStyle, actionHandler: (() -> Void)?) {
        self.init(title: title, style: style, target: nil, action: nil)
        self.target = self
        self.action = #selector(MESplitViewControllerBarButtonItem.triggerClosureAction(_:))
        self.actionHandler = actionHandler
    }
    public func triggerClosureAction(_ sender: UIBarButtonItem) {
        if let actionHandler = self.actionHandler {
            actionHandler()
        }
    }
}
