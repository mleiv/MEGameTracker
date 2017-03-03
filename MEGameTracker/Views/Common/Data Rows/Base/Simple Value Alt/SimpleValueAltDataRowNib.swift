//
//  SimpleValueAltDataRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable open class SimpleValueAltDataRowNib: SimpleValueDataRowNib {
    
    override open class func loadNib(heading: String? = nil) -> SimpleValueAltDataRowNib? {
        let bundle = Bundle(for: SimpleValueAltDataRowNib.self)
        if let view = bundle.loadNibNamed("SimpleValueAltDataRowNib", owner: self, options: nil)?.first as? SimpleValueAltDataRowNib {
            view.headingLabel?.text = heading?.isEmpty == false ? "\(heading ?? ""): " : nil
            return view
        }
        return nil
    }
}
 
