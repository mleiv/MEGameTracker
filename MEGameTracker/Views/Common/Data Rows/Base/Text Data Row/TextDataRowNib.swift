//
//  TextDataRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

open class TextDataRowNib: HairlineBorderView {
    
    @IBOutlet open weak var textView: MarkupTextView?
    
    @IBOutlet open weak var leadingPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var trailingPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var bottomPaddingConstraint: NSLayoutConstraint?
    @IBOutlet open weak var topPaddingConstraint: NSLayoutConstraint?
    
    @IBOutlet open weak var rowDivider: HairlineBorderView?
    
    open class func loadNib() -> TextDataRowNib? {
        let bundle = Bundle(for: TextDataRowNib.self)
        if let view = bundle.loadNibNamed("TextDataRowNib", owner: self, options: nil)?.first as? TextDataRowNib {
            return view
        }
        return nil
    }
}
