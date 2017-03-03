//
//  UIHeaderTab.swift
//
//  Created by Emily Ivie on 9/10/15.
//  Copyright © 2015 urdnot.

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

final public class UIHeaderTab: UIView {
    
    @IBOutlet weak var unselectedWrapper: UIView?
    @IBOutlet weak var selectedWrapper: UIView?
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var label1: UILabel?
    @IBOutlet weak var label2: UILabel?
    @IBOutlet weak var selectedUnderline: UIView?
    
    var selected: Bool = false
    var index: Int = 0
    var onClick: ((Int) -> Void)?
    
    @IBAction func onClick(_ sender: UIButton) {
        onClick?(index)
    }
    
    public func setup(title: String, selected: Bool = false, index: Int = 0, onClick: ((Int) -> Void)? = nil) {
        self.index = index
        label1?.text = title
        label2?.text = title
        self.selected = selected
        unselectedWrapper?.isHidden = selected
        selectedWrapper?.isHidden = !selected
        self.onClick = onClick
        layoutIfNeeded()
    }
}
 
