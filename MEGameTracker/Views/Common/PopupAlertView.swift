////
////  PopupAlertView.swift
////  MEGameTracker
////
////  Created by Emily Ivie on 3/14/16.
////  Copyright © 2016 Emily Ivie. All rights reserved.
////
//
//import UIKit
//
//public struct PopupAlertView {
//    private weak var parent: UIViewController? //the view that will be concealed by the spinner and its background overlay
//    private weak var internalView: UIView?
//    
//    private var overlay: UIView!
//    private var isSetup = false
//    
//    public init(parent: UIViewController, internalView: UIView) {
//        self.parent = parent
//        self.internalView = internalView
//    }
//    
//    public mutating func setup() {
//        guard let parent = self.parent, let internalView = internalView else { return }
//        
//        //create overlay
//        overlay = UIView()
//        overlay.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
//        overlay.opaque = false
//        overlay.hidden = true
//        parent.view.addSubview(overlay)
//        
//        //size to fit
//        overlay.translatesAutoresizingMaskIntoConstraints = false
//        overlay.leadingAnchor.constraintEqualToAnchor(parent.view.leadingAnchor).active = true
//        overlay.trailingAnchor.constraintEqualToAnchor(parent.view.trailingAnchor).active = true
//        overlay.topAnchor.constraintEqualToAnchor(parent.view.topAnchor).active = true
//        overlay.bottomAnchor.constraintEqualToAnchor(parent.view.bottomAnchor).active = true
//        
//        //create wrapper
//        let wrapper = HairlineBorderView()
//        wrapper.left = true
//        wrapper.top = true
//        wrapper.right = true
//        wrapper.bottom = true
//        overlay.addSubview(wrapper)
//        wrapper.addSubview(internalView)
//        
//        //size to fit
//        wrapper.translatesAutoresizingMaskIntoConstraints = false
//        wrapper.leadingAnchor.constraintGreaterThanOrEqualToAnchor(overlay.leadingAnchor, constant: 15).active = true
//        wrapper.trailingAnchor.constraintGreaterThanOrEqualToAnchor(overlay.trailingAnchor, constant: 15).active = true
//        wrapper.topAnchor.constraintGreaterThanOrEqualToAnchor(overlay.topAnchor, constant: 15).active = true
//        wrapper.bottomAnchor.constraintGreaterThanOrEqualToAnchor(overlay.bottomAnchor, constant: 15).active = true
//        wrapper.centerXAnchor.constraintEqualToAnchor(overlay.centerXAnchor).active = true
//        wrapper.centerYAnchor.constraintEqualToAnchor(overlay.centerYAnchor).active = true
//        
//        internalView.translatesAutoresizingMaskIntoConstraints = false
//        internalView.leadingAnchor.constraintEqualToAnchor(wrapper.leadingAnchor).active = true
//        internalView.trailingAnchor.constraintEqualToAnchor(wrapper.trailingAnchor).active = true
//        internalView.topAnchor.constraintEqualToAnchor(wrapper.topAnchor).active = true
//        internalView.bottomAnchor.constraintEqualToAnchor(wrapper.bottomAnchor).active = true
//        
//        //done!
//        isSetup = true
//    }
//    
//    public mutating func start() {
//        if !isSetup {
//            setup()
//        }
//        overlay?.hidden = false
//    }
//    
//    public func stop() {
//        overlay?.hidden = true
//    }
//}
