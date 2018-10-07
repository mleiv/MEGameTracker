//
//  UIView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/30/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

extension UIView {
	public func fillView(_ view: UIView!, margin: CGFloat = 0) {
		translatesAutoresizingMaskIntoConstraints = false
		leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
		trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
		topAnchor.constraint(equalTo: view.topAnchor, constant: margin).isActive = true
		bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).isActive = true
	}
	public func constraintCenterTo(_ view: UIView!) {
		centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
	}

//	// Just an idea, not yet tested
//	public func replaceViewKeepConstraints(view: UIView){
//		if let constraints = view.constraints() as? [NSLayoutConstraint] {
//			for constraint in constraints {
//				if constraint.firstItem === view {
//					var newConstraint = constraint
//					newConstraint.firstItem = self
//					addConstraint(newConstraint)
//				}

//				if constraint.secondItem === view {
//					var newConstraint = constraint
//					newConstraint.secondItem = self
//					addConstraint(newConstraint)
//				}

//			}

//		}

//		view.superview?.insertSubview(self, aboveSubview: view)
//		view.removeFromSuperview()
//	}
}

extension UIView {
	func clone() -> UIView! {
        if let viewData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true),
            let view = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIView.self, from: viewData) {
            return view
        }
		//snapshotViewAfterScreenUpdates ?
        return nil
	}
}
