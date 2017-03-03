//
//  SliderRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable final public class SliderRowNib: HairlineBorderView {

    @IBOutlet weak var headingLabel: IBStyledLabel?
    @IBOutlet public weak var slider: UISlider?
    
    @IBOutlet weak var rowDivider: HairlineBorderView?
    
    public var onChangeBlock: ((_ sender: UIView?) -> Void) = { _ in }
    public var onFinishedChangeBlock: ((_ sender: UIView?) -> Void) = { _ in }
    
    @IBAction func onChange(_ sender: UISlider?) {
        onChangeBlock(sender)
    }
    @IBAction func onFinishedChange(_ sender: UISlider?) {
        onFinishedChangeBlock(sender)
    }
    
    public class func loadNib(heading: String? = nil) -> SliderRowNib? {
        let bundle = Bundle(for: SliderRowNib.self)
        if let view = bundle.loadNibNamed("SliderRowNib", owner: self, options: nil)?.first as? SliderRowNib {
            view.headingLabel?.text = heading?.isEmpty == false ? "\(heading ?? ""): " : nil
            return view
        }
        return nil
    }
}
 
