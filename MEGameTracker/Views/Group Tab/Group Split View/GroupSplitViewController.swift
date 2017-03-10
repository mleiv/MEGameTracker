//
//  GroupsSplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

class GroupSplitViewController: UIViewController, MESplitViewController, DeepLinkable {

	@IBOutlet weak var mainPlaceholder: IBIncludedSubThing?
	@IBOutlet weak var detailBorderLeftView: UIView?
	@IBOutlet weak var detailPlaceholder: IBIncludedSubThing?
	var ferriedSegue: FerriedPrepareForSegueClosure?
	var dontSplitViewInPage = false

	@IBAction func closeDetailStoryboard(_ sender: AnyObject?) {
		closeDetailStoryboard()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		ferriedSegue?(segue.destination)
	}

	// MARK: DeepLinkable protocol

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let person = deepLinkedPerson {
			showPerson(person)
		}
		isPageLoaded = true
	}

	var deepLinkedPerson: Person?
	var isPageLoaded = false

	func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		// first, verify is acceptable object:
		if let person = object as? Person {
			// second, make sure page is done loading:
			if isPageLoaded {
				showPerson(person)
			} else {
				deepLinkedPerson = person // wait for viewWillAppear()
			}
		}
	}

	func showPerson(_ person: Person) {
		deepLinkedPerson = nil
		(mainPlaceholder?.includedController as? PersonsGroupsController)?.deepLink(person)
	}
}
