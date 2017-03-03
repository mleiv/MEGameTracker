//
//  RadioOptionRowNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//
import UIKit

@IBDesignable final public class RadioOptionRowNib: HairlineBorderView {

    @IBOutlet weak var headingLabel: IBStyledLabel?
    @IBOutlet weak var radioButton: RadioButton?
    
    @IBOutlet weak var rowDivider: HairlineBorderView?
    
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    public var onChange: ((_ sender: UIView?) -> Void) = { _ in }
    
    @IBAction func _onChange(_ sender: UIButton?) {
        radioButton?.toggle(isOn: !(radioButton?.isOn ?? false))
        onChange(sender)
    }
    @IBAction func _onClick(_ sender: UIButton?) {
        onClick(sender)
    }
    
    public class func loadNib() -> RadioOptionRowNib? {
        let bundle = Bundle(for: RadioOptionRowNib.self)
        if let view = bundle.loadNibNamed("RadioOptionRowNib", owner: self, options: nil)?.first as? RadioOptionRowNib {
            return view
        }
        return nil
    }
}
 
