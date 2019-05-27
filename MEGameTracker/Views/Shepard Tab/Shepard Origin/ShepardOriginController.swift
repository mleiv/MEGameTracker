//
//  ShepardOriginController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class ShepardOriginController: UIViewController, SideEffectsable {

	@IBOutlet weak var earthbornRadio: RadioOptionRowView?
	@IBOutlet weak var earthbornSideEffectsView: SideEffectsView?
	@IBOutlet weak var spacerRadio: RadioOptionRowView?
	@IBOutlet weak var spacerSideEffectsView: SideEffectsView?
	@IBOutlet weak var colonistRadio: RadioOptionRowView?
	@IBOutlet weak var colonistSideEffectsView: SideEffectsView?

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
			earthbornSideEffectsView?.controller = self
			spacerSideEffectsView?.controller = self
			colonistSideEffectsView?.controller = self

			earthbornRadio?.onChange = { [weak self] _ in
                self?.handleChange(origin: .earthborn)
			}
			spacerRadio?.onChange = { [weak self] _ in
                self?.handleChange(origin: .spacer)
			}
			colonistRadio?.onChange = { [weak self] _ in
                self?.handleChange(origin: .colonist)
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
		earthbornRadio?.isOn = shepard.origin == .earthborn
		spacerRadio?.isOn = shepard.origin == .spacer
		colonistRadio?.isOn = shepard.origin == .colonist
	}

    func handleChange(origin: Shepard.Origin) {
        if let shepard = self.shepard?.changed(origin: origin) {
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
		_ = App.onCurrentShepardChange.subscribe(with: self, callback: reloadOnShepardChange)
	}
}
