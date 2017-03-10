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
	fileprivate var shepard: Shepard?

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
				self?.shepard?.change(reputation: .ruthless)
				self?.setupRadios()
			}
			warHeroRadio?.onChange = { [weak self] _ in
				self?.shepard?.change(reputation: .warHero)
				self?.setupRadios()
			}
			soleSurvivorRadio?.onChange = { [weak self] _ in
				self?.shepard?.change(reputation: .soleSurvivor)
				self?.setupRadios()
			}
		}

		setupRadios()
	}

	func fetchData() {
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		shepard = App.current.game?.shepard
	}

	func fetchDummyData() {
		shepard = Shepard.getDummy()
	}

	func setupRadios() {
		ruthlessRadio?.isOn = shepard?.reputation == .ruthless
		warHeroRadio?.isOn = shepard?.reputation == .warHero
		soleSurvivorRadio?.isOn = shepard?.reputation == .soleSurvivor
	}

	func reloadDataOnChange() {
		DispatchQueue.main.async {
			self.fetchData()
			self.setupRadios()
		}
	}

	func reloadOnShepardChange() {
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
