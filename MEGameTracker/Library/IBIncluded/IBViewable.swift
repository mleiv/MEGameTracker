//
//  IBIncludedView.swift
//  IBIncludedThingDemo
//
//  Created by Emily Ivie on 3/7/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

/// Provides a method for previewing nib views inside storyboards.
/// 
/// Usage Example:
///
///    public var isLoadedAttachedNib = false
///    public var isLoadedNib = false
///    open override func draw(_ rect: CGRect) {
///    		if !attachedNib() {
///    			// now you can make changes and they will appear in both nib and storyboard
///    			super.draw(rect)
///    		}
///    	}
public protocol IBViewable: class {
	// Required
	var isLoadedNib: Bool { get set }
	var isLoadedAttachedNib: Bool { get set }
	// Optional
	var isInterfaceBuilder: Bool { get }
	func attachedNib<T: UIView>(nibName: String?) -> T?
	func attachedNib<T: UIView>() -> T?
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

	public var isInterfaceBuilder: Bool {
        #if TARGET_INTERFACE_BUILDER
            return true
        #else
            return false
        #endif
    }
	
	public func attachedNib<T: UIView>(nibName: String?) -> T? {
		guard superview != nil && !(isLoadedNib || isLoadedAttachedNib) else {
			if let view = subviews.first as? T {
				return view
			}
			return self as? T
		}
		isLoadedNib = true
		// try to automatically discover nib filename
		let className = String(describing: Self.self)
		// use explicit bundle (IB is picky)
		let bundle = Bundle(for: type(of: self))
		// load nib and add to hierarchy
		if let nib = bundle.loadNibNamed(nibName ?? className, owner: self, options: nil)?.first as? Self {
//			let superview = superview,
//			let index = superview.subviews.index(of: self) {
			nib.isLoadedAttachedNib = true
			addSubview(nib)
			nib.translatesAutoresizingMaskIntoConstraints = false
			nib.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			nib.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
			nib.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
			nib.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//			superview.insertSubview(nib, at: index)
//			transferViewProperties(from: self, to: nib)
//			removeFromSuperview()
			return nib as? T
		}
		return nil
	}
	
	public func attachedNib<T: UIView>() -> T? { return attachedNib(nibName: nil) }
	
	private func transferViewProperties(from fromView: UIView, to toView: UIView) {
		toView.frame = fromView.frame
		toView.translatesAutoresizingMaskIntoConstraints = fromView.translatesAutoresizingMaskIntoConstraints
		toView.clipsToBounds = fromView.clipsToBounds
		transferConstraints(from: fromView, to: toView)
		transferSuperviewConstraints(from: fromView, to: toView, in: fromView.superview)
		if toView.backgroundColor == .clear {
			toView.backgroundColor = .clear
			toView.isOpaque = true // mandatory, or will draw it black
		} else if !fromView.isOpaque {
			toView.isOpaque = fromView.isOpaque
		}
		if fromView.alpha != 1.0 {
			toView.alpha = fromView.alpha
		}
		toView.restorationIdentifier = fromView.restorationIdentifier
		toView.tag = fromView.tag
		toView.isHidden = fromView.isHidden
	}
	
	private func transferConstraints(from fromView: UIView, to toView: UIView) {
		for constraint in fromView.constraints {
			// matches constraint first element, copy
			if fromView == constraint.firstItem as? Self {
				fromView.removeConstraint(constraint)
				toView.addConstraint(NSLayoutConstraint(item: toView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			// matches constraint second element, copy
			} else if fromView == constraint.secondItem as? Self {
				fromView.removeConstraint(constraint)
				toView.addConstraint(NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: toView, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
		}
	}
	private func transferSuperviewConstraints(from fromView: UIView, to toView: UIView, in inView: UIView?) {
		// require superview
		guard let superview = inView else { return }
		// recurse up to gather constraints
		transferSuperviewConstraints(from: fromView, to: toView, in: superview.superview)
		// skip on empty
		guard !superview.constraints.isEmpty else { return }
		// iterate through all constraints
		for constraint in superview.constraints {
			// matches constraint first element, copy
			if fromView == constraint.firstItem as? Self {
				superview.removeConstraint(constraint)
				superview.addConstraint(NSLayoutConstraint(item: toView, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: constraint.secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			// matches constraint second element, copy
			} else if fromView == constraint.secondItem as? Self {
				superview.removeConstraint(constraint)
				superview.addConstraint(NSLayoutConstraint(item: constraint.firstItem, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: toView, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
			}
		}
	}
}

