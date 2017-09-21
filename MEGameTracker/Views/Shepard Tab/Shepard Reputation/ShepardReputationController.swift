//
//  ShepardReputationController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class ShepardReputationController: UIViewController, SideEffectsable {

	@IBOutlet weak var ruthlessRadio: RadioOptionRowView?
	@IBOutlet weak var ruthlessSideEffectsView: SideEffectsView?
	@IBOutlet weak var warHeroRadio: RadioOptionRowView?
	@IBOutlet weak var warHeroSideEffectsView: SideEffectsView?
	@IBOutlet weak var soleSurvivorRadio: RadioOptionRowView?
	@IBOutlet weak var soleSurvivorSideEffectsView: SideEffectsView?

	public var sideEffects: [String]?
	private var shepard: Shepard?

	override public func viewDidLoad() {
		super.viewDidLoad()
		guard !UIWindow.isInterfaceBuilder else { return }
		setup()
		startListeners()
	}

	func setup() {
		fetchData()

		if !UIWindow.isInterfaceBuilder {
			ruthlessSideEffectsView?.controller = self
			warHeroSideEffectsView?.controller = self
			soleSurvivorSideEffectsView?.controller = self

			ruthlessRadio?.onChange = { [weak self] _ in
				self?.handleChange(reputation: .ruthless)
			}
			warHeroRadio?.onChange = { [weak self] _ in
				self?.handleChange(reputation: .warHero)
			}
			soleSurvivorRadio?.onChange = { [weak self] _ in
				self?.handleChange(reputation: .soleSurvivor)
			}
		}

		if let shepard = self.shepard {
			setupRadios(shepard: shepard)
		}
	}

	func fetchData() {
		if UIWindow.isInterfaceBuilder {
			shepard = Shepard.getDummy()
		} else {
			shepard = App.current.game?.shepard
		}
	}

	func setupRadios(shepard: Shepard) {
		ruthlessRadio?.isOn = shepard.reputation == .ruthless
		warHeroRadio?.isOn = shepard.reputation == .warHero
		soleSurvivorRadio?.isOn = shepard.reputation == .soleSurvivor
	}

	func handleChange(reputation: Shepard.Reputation) {
        if let shepard = self.shepard?.changed(reputation: reputation) {
            setupRadios(shepard: shepard)
        }
	}

	func reloadDataOnChange() {
		DispatchQueue.main.async { [weak self] in
			self?.fetchData()
			if let shepard = self?.shepard {
				self?.setupRadios(shepard: shepard)
			}
		}
	}

	func reloadOnShepardChange(_ x: Bool = false) {
		if shepard?.uuid != App.current.game?.shepard?.uuid {
			shepard = App.current.game?.shepard
			reloadDataOnChange()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes only
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
	}
}
