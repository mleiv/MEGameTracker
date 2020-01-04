//
//  GameSegmentsNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class GameSegmentsNib: UIView {

	@IBOutlet public weak var game1: UILabel?
	@IBOutlet public weak var game2: UILabel?
	@IBOutlet public weak var game3: UILabel?

	public class func loadNib() -> GameSegmentsNib? {
		let bundle = Bundle(for: GameSegmentsNib.self)
		if let view = bundle.loadNibNamed("GameSegmentsNib", owner: self, options: nil)?.first as? GameSegmentsNib {
			return view
		}
		return nil
	}
}
