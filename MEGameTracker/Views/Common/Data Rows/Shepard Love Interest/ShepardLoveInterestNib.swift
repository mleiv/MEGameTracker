//
//  ShepardLoveInterestNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable final public class ShepardLoveInterestNib: SimpleValueAltDataRowNib {
    
    @IBOutlet weak var loveInterestImageView: UIImageView?
    
    override public class func loadNib(heading: String? = nil) -> ShepardLoveInterestNib? {
        let bundle = Bundle(for: ShepardLoveInterestNib.self)
        if let view = bundle.loadNibNamed("ShepardLoveInterestNib", owner: self, options: nil)?.first as? ShepardLoveInterestNib {
            view.headingLabel?.text = heading?.isEmpty == false ? "\(heading ?? ""): " : nil
            return view
        }
        return nil
    }
}
 
