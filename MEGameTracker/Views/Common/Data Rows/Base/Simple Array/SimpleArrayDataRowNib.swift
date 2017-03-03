//
//  SimpleArrayDataRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable open class SimpleArrayDataRowNib: HairlineBorderView {

    @IBOutlet weak var headingLabelWrapper: UIView?
    @IBOutlet weak var headingLabel: IBStyledLabel?
    @IBOutlet open weak var tableView: LayoutNotifyingTableView?
    
    open class func loadNib(heading: String? = nil, cellNibs: [String] = []) -> SimpleArrayDataRowNib? {
        let bundle = Bundle(for: SimpleArrayDataRowNib.self)
        if let view = bundle.loadNibNamed("SimpleArrayDataRowNib", owner: self, options: nil)?.first as? SimpleArrayDataRowNib {
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
 
