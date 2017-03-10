//
//  RoundedCornersBox.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornersBox: UIView {
	@IBInspectable var cornerRadius: CGFloat = 10
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	func setup() {
		layer.cornerRadius = CGFloat(cornerRadius)
		layer.masksToBounds = true
	}
}
