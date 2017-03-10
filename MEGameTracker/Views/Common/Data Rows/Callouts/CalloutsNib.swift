//
//  CalloutsNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/9/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable open class CalloutsNib: SimpleArrayDataRowNib {

	override open class func loadNib(heading: String? = nil, cellNibs: [String] = []) -> CalloutsNib? {
		let bundle = Bundle(for: CalloutsNib.self)
		if let view = bundle.loadNibNamed("CalloutsNib", owner: self, options: nil)?.first as? CalloutsNib {
			let bundle =  Bundle(for: CalloutsNib.self)
			for nib in cellNibs {
				view.tableView?.register(UINib(nibName: nib, bundle: bundle), forCellReuseIdentifier: nib)
			}
			return view
		}
		return nil
	}
}
