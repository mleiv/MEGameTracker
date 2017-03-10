//
//  MapsFlowController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

class MapsFlowController: IBIncludedThing {

	@IBAction func closeCallouts(_ sender: AnyObject!) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func openCallouts(_ sender: AnyObject!) {
		if let controller = childViewControllers.first as? MapSplitViewController {
			let ferriedSegue: FerriedPrepareForSegueClosure = controller.ferriedSegueForCallouts
			if controller.isCalloutsOpen {
				controller.closeDetailStoryboard(sender)
			} else {
				controller.performChangeableSegue("Open MapsFlow.Callouts", sender: sender, ferriedSegue: ferriedSegue)
			}
		}
	}

}
