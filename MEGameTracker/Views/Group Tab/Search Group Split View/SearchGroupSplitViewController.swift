//
//  SearchGroupSplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/29/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class SearchGroupSplitViewController: UIViewController, MESplitViewController {

    @IBOutlet weak public var mainPlaceholder: IBIncludedSubThing?
    @IBOutlet weak public var detailBorderLeftView: UIView?
    @IBOutlet weak public var detailPlaceholder: IBIncludedSubThing?
    public var ferriedSegue: FerriedPrepareForSegueClosure?
    public var dontSplitViewInPage = false
    
    @IBAction public func closeDetailStoryboard(_ sender: AnyObject?) {
        closeDetailStoryboard()
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ferriedSegue?(segue.destination)
    }
}
