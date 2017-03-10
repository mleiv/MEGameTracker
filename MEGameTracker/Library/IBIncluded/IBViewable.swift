//
//  IBViewable.swift
//
//  Created by Emily Ivie on 3/7/17.
//  Copyright © 2017 urdnot. All rights reserved.
//

import UIKit

/// Provides functionality for previewing nib views inside storyboards.
/// 
/// Usage Example:
///
/// @IBDesignable class TestView: UIView, IBViewable {
///	public var isAttachedNibWrapper = false
///	public var isAttachedNib = false
///	override public func awakeFromNib() {
///		super.awakeFromNib()
///		_ = attachOrAttachedNib()
///	}

///	   override public func prepareForInterfaceBuilder() {
///		_ = attachOrAttachedNib()
///		super.prepareForInterfaceBuilder()
///	}

///	override public func layoutSubviews() {
///		super.layoutSubviews()
///		if isAttachedNib {
///			// ... do stuff (*don't* do stuff if isAttachedNibWrapper)
///		}

///	}

/// }
public protocol IBViewable: class {

// MARK: Required

	/// Marks an IBViewable UIView which has an attached view as a child.
	var isAttachedNibWrapper: Bool { get set }

	/// Marks the attached view of an IBViewable UIView.
	var isAttachedNib: Bool { get set }

// MARK: Optional

	/// Returns the attached view, or creates it.
	func attachOrAttachedNib() -> Self?

// MARK: Defined

	/// Set the nibName if the nib has a different name than the UIView class.
	var nibName: String? { get }

	/// Returns whether the current environment is Interface Builder.
	/// Note: prepareForInterfaceBuilder is not a reliable gauge for this flag.
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

	/// (Protocol default)
	/// Returns whether the current environment is Interface Builder.
	/// Note: prepareForInterfaceBuilder is not a reliable gauge for this flag.
	public func attachOrAttachedNib() -> Self? {
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

	/// (Protocol default)
	/// Set the nibName if the nib has a different name than the UIView class.
	public var nibName: String? { return nil }

	/// (Protocol default)
	/// Returns whether the current environment is Interface Builder.
	/// Note: prepareForInterfaceBuilder is not a reliable gauge for this flag.
	public var isInterfaceBuilder: Bool {
		#if TARGET_INTERFACE_BUILDER
			return true
		#else
			return false
		#endif
	}
}
