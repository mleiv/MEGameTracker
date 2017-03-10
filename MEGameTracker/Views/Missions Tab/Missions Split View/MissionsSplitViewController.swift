//
//  MissionsSplitViewController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/24/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final class MissionsSplitViewController: UIViewController, MESplitViewController {

	@IBOutlet weak var mainPlaceholder: IBIncludedSubThing?
	@IBOutlet weak var detailBorderLeftView: UIView?
	@IBOutlet weak var detailPlaceholder: IBIncludedSubThing?
	var ferriedSegue: FerriedPrepareForSegueClosure?

	// set by parent, shared with child:
	var missionsType: MissionType = .mission
	var missionsCount: Int = 0
	var missions: [Mission] = []
	var deepLinkedMission: Mission?
	var isLoadedSignal: Signal<(type: MissionType, values: [Mission])>?

	var isPageLoaded = false
	var dontSplitViewInPage = false

	@IBAction func closeDetailStoryboard(_ sender: AnyObject?) {
		closeDetailStoryboard()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		ferriedSegue?(segue.destination)
	}
}

extension MissionsSplitViewController: DeepLinkable {

	// MARK: DeepLinkable protocol

	func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			if let mission = object as? Mission {
				self?.deepLinkedMission = mission // passthrough
				// reload missions page?
			}
		}
	}
}
