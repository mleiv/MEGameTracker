//
//  NotesEditorController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class NotesEditorController: UIViewController {
    
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint?
    
    public var note: Note?
    public var isPopover: Bool { return popover?.arrowDirection != .unknown }
    public weak var popover: UIPopoverPresentationController?
    
    // OriginHintable
    @IBOutlet weak var originHintView: TextDataRow?
    lazy var originHintType: OriginHintType = { return OriginHintType(controller: self, view: self.originHintView) }()
    public var originHint: String?
    public var originPrefix: String?
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if !isPopover {
            registerForKeyboardNotifications()
        }
    }
    
    deinit {
        if !isPopover {
            deregisterForKeyboardNotifications()
        }
    }
    
    var didSetup = false
    
    func setup() {
        textView?.text = note?.text ?? ""
        
        if isPopover {
            originHint = nil
        }
        
        setupOriginHint()
        
        didSetup = true
        
        startEditing()
    }
    
    func startEditing() {
        // open keyboard
        textView?.becomeFirstResponder()
        // go to end of note
        textView?.selectedRange = NSMakeRange(textView?.text.length ?? 0, 0)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        textView?.resignFirstResponder()
        closeWindow()
    }
    
    @IBAction func save(_ sender: AnyObject) {
        textView?.resignFirstResponder()
        if var note = note {
            note.change(text: textView?.text ?? "", isSave: false)
            if note.saveAnyChanges() {
                closeWindow()
            }
        }
        
    }
    
    func closeWindow() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(NotesEditorController.keyboardWillBeShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(NotesEditorController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    func deregisterForKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    func keyboardWillBeShown(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
            keyboardHeightConstraint?.constant = CGFloat(keyboardSize.height)
        }
    }
    func keyboardWillBeHidden(_ notification: Notification) {
        keyboardHeightConstraint?.constant = 0
    }
}

extension NotesEditorController: OriginHintable {
    // var originHint: String? // already declared
    public func setupOriginHint() {
        originHintType.setupView()
    }
}


