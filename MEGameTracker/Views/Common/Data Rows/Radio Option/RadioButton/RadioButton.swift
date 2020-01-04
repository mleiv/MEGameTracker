//
//  RadioButton.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/12/2016.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable open class RadioButton: UIView {
	@IBInspectable var isOn: Bool = false

	public var enabled = true {
		didSet {
			nib?.alpha = enabled ? 1.0 : 0.5
		}
	}

	public var onClick: ((AnyObject?) -> Void)?

	internal var didSetup = false
	internal var nib: RadioButtonNib?

	open override func layoutSubviews() {
		if !didSetup {
			setup()
		}
		super.layoutSubviews()
	}

	open func setup() {
		if nib == nil, let view = RadioButtonNib.loadNib() {
			insertSubview(view, at: 0)
			view.fillView(self)
			nib = view
		}
		if let view = nib {
			view.radioOn?.isHidden = !isOn
			view.alpha = enabled ? 1.0 : 0.5
			view.parent = self
			didSetup = true
		}
	}

	open func toggle(isOn: Bool) {
		guard isOn != self.isOn else { return }
		self.isOn = isOn
		nib?.radioOn?.isHidden = !isOn
	}

	/// defaults to onChange behavior if no onClick was set
	public func click(_ sender: AnyObject?) {
		if onClick != nil && enabled {
			toggle(isOn: !isOn)
//			isOn = !isOn
//			nib?.radioOn?.isHidden = !isOn
			onClick?(self)
		}
	}
}
@IBDesignable final public class RadioButtonNib: UIView {

	@IBOutlet weak var radioOff: UIImageView?
	@IBOutlet weak var radioOn: UIImageView?
	weak var parent: RadioButton?

	@IBAction func onClick(_ sender: AnyObject?) {
		parent?.click(sender)
	}

	public class func loadNib(onImage: UIImage? = nil, offImage: UIImage? = nil) -> RadioButtonNib? {
		let bundle = Bundle(for: RadioButtonNib.self)
		if let view = bundle.loadNibNamed("RadioButtonNib", owner: self, options: nil)?.first as? RadioButtonNib {
			if let onImage = onImage {
				view.radioOn?.image = onImage
			}
			if let offImage = offImage {
				view.radioOff?.image = offImage
			}
			return view
		}
		return nil
	}
}
