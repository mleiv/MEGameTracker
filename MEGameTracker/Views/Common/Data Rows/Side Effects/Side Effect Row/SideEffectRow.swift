//
//  SideEffectRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class SideEffectRow: UITableViewCell {

// MARK: Types
// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var textView: MarkupTextView?

// MARK: Properties
	internal fileprivate(set) var sideEffect: String?
	private var parent: SideEffectsView?

// MARK: Change Listeners And Change Status Flags
	private var isDefined = false

// MARK: Lifecycle Events
	public override func layoutSubviews() {
		if !isDefined {
			clearRow()
		}
		super.layoutSubviews()
	}

// MARK: Initialization
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(sideEffect: String?, parent: SideEffectsView? = nil) {
		isDefined = true
		self.sideEffect = sideEffect
		self.parent = parent
		setup()
	}

// MARK: Populate Data
	private func setup() {
		guard textView != nil else { return }
		backgroundColor = UIColor.clear
		textView?.text = sideEffect
		textView?.linkOriginController = parent?.viewController
        textView?.textContainerInset = UIEdgeInsets.zero
        layoutIfNeeded()
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		textView?.text = ""
	}
}
