//
//  ShepardSplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public final class ShepardSplitViewController: UIViewController, MESplitViewController {

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
