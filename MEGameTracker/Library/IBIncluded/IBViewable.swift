//
//  IBViewable.swift
//
//  Created by Emily Ivie on 3/7/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

/// Provides a method for previewing nib views inside storyboards.
/// 
/// Usage Example:
///
///    public var isAttachedNibWrapper = false
///    public var isAttachedNib = false
///    open override func draw(_ rect: CGRect) {
///    		if !attachedNib() {
///    			// now you can make changes and they will appear in both nib and storyboard
///    			super.draw(rect)
///    		}
///    	}
public protocol IBViewable: class {
	// Required
	var isAttachedNibWrapper: Bool { get set }
	var isAttachedNib: Bool { get set }
	// Optional
	func attachedNib() -> Self?
	// Defined
	var nibName: String? { get }
	var isInterfaceBuilder: Bool { get }
}

extension IBViewable where Self: UIView {

// UIView LifeCycle inside Interface Builder:
//
// willMove(toSuperview newSuperview: UIView?)
// didMoveToSuperview()
// layoutSubviews()
// prepareForInterfaceBuilder() // no constraints yet
// --Below is the point at which we have constraints, but it causes problems if we make changes there.
// willMove(toWindow newWindow: UIWindow?) 
// didMoveToWindow()
// draw(_ rect: CGRect)
//
// If we swap in a view, order changes and prepareForInterfaceBuilder is never called:
//
// willMove(toWindow newWindow: UIWindow?)
// didMoveToWindow()
// willMove(toSuperview newSuperview: UIView?)
// didMoveToSuperview()
// layoutSubviews()
// draw(_ rect: CGRect)
	
	public func attachedNib() -> Self? {
		// check if already loaded and return that instead
		guard !isAttachedNib else {
			return self
		}
		guard !isAttachedNibWrapper else {
			if let nib = subviews.first as? Self, nib.isAttachedNib {
				return nib
			}
			return nil
		}
		// dual-purpose: recognize newly-created to-be-attached nibs, and independant nib files in IB.
		//   this prevents endless recursions of attached nibs when loading,
		//   and keeps independant nib files untouched (so we can continue editing them as-is)
		guard superview != nil else {
			isAttachedNib = true
			return self
		}
		isAttachedNibWrapper = true
		// try to automatically discover nib filename
		let className = String(describing: Self.self)
		// use explicit bundle (IB is picky)
		let bundle = Bundle(for: type(of: self))
		// load nib and add to hierarchy
		if let nib = bundle.loadNibNamed(nibName ?? className, owner: self, options: nil)?.first as? Self {
			nib.isAttachedNib = true
			addSubview(nib)
			nib.translatesAutoresizingMaskIntoConstraints = false
			nib.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			nib.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			nib.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			nib.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
			return nib
		}
		return nil
	}

	public var nibName: String? { return nil }
	
	public var isInterfaceBuilder: Bool {
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }
}

