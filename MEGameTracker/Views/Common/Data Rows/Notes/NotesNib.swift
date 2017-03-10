//
//  NotesNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable final public class NotesNib: SimpleArrayDataRowNib {

	@IBOutlet weak var addButton: UIButton?
	@IBOutlet weak var addLabel: IBStyledLabel?

	public var onAdd: (() -> Void)?

	@IBAction func addButtonClicked(_ sender: UIButton) {
		onAdd?()
	}

	override public class func loadNib(heading: String? = nil, cellNibs: [String] = []) -> NotesNib? {
		let bundle = Bundle(for: NotesNib.self)
		if let view = bundle.loadNibNamed("NotesNib", owner: self, options: nil)?.first as? NotesNib {
			view.headingLabel?.text = heading
			if heading?.isEmpty ?? true {
				view.headingLabelWrapper?.isHidden = true
			}
			let bundle =  Bundle(for: SimpleArrayDataRowNib.self)
			for nib in cellNibs {
				view.tableView?.register(UINib(nibName: nib, bundle: bundle), forCellReuseIdentifier: nib)
			}
			return view
		}
		return nil
	}
}
