//
//  SimpleValueDataRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/25/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable open class SimpleValueDataRowNib: HairlineBorderView {

    @IBOutlet weak var headingLabel: IBStyledLabel?
    @IBOutlet weak var valueLabel: IBStyledLabel?
    @IBOutlet weak var disclosureImageView: UIImageView?
    @IBOutlet weak var button: UIButton?
    
    @IBOutlet weak var rowDivider: HairlineBorderView?
    
    open var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        onClick(sender)
    }
    
    open class func loadNib(heading: String? = nil) -> SimpleValueDataRowNib? {
        let bundle = Bundle(for: SimpleValueDataRowNib.self)
        if let view = bundle.loadNibNamed("SimpleValueDataRowNib", owner: self, options: nil)?.first as? SimpleValueDataRowNib {
            view.headingLabel?.text = heading
            return view
        }
        return nil
    }
}
 
