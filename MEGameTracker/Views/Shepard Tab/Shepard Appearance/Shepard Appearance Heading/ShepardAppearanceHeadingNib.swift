//
//  ShepardAppearanceHeadingNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/27/2016.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

class ShepardAppearanceHeadingNib: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    class func loadNib(title: String?) -> ShepardAppearanceHeadingNib? {
        let bundle = Bundle(for: ShepardAppearanceHeadingNib.self)
        if let view = bundle.loadNibNamed("ShepardAppearanceHeadingNib", owner: self, options: nil)?.first as? ShepardAppearanceHeadingNib {
            view.titleLabel.text = title
            return view
        }
        return nil
    }
}
 
