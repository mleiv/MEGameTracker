//
//  DecisionDetailController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class DecisionDetailController: UIViewController {
    
    @IBOutlet weak var originHintLabel: UILabel?
    @IBOutlet weak var titleLabel: MarkupLabel?
    @IBOutlet weak var gameLabel: IBStyledLabel!
    @IBOutlet weak var textView: MarkupTextView?
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint?
    
    // exposed to calling controller:
    public var decision: Decision?
    public var originHint: String?
    public var isPopover = false
    public weak var decisionsView: DecisionsView?
    public weak var popover: UIPopoverPresentationController?
    
    var didSetup = false
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        isPopover = popover?.arrowDirection != .unknown
        titleLabel?.text = decision?.name
        textView?.text = decision?.description
        textView?.linkOriginController = decisionsView?.viewController
        originHintLabel?.text = "RE: \(originHint ?? "")"
        originHintLabel?.superview?.isHidden = isPopover || (originHint?.isEmpty ?? true)
        didSetup = true
        view.layoutIfNeeded()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        textView?.resignFirstResponder()
        closeWindow()
    }
    
    func closeWindow() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}


