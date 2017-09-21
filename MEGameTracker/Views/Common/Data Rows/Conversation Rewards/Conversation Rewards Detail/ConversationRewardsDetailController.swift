//
//  ConversationRewardsDetailController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5.25/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

final public class ConversationRewardsDetailController: UITableViewController {

	public var mission: Mission?
	var rewards: [ConversationRewards.FlatData] = []

	// originHintable 
	@IBOutlet weak var originHintView: TextDataRow?
	lazy var originHintType: OriginHintType = { return OriginHintType(controller: self, view: self.originHintView) }()
	public var originHint: String?
	public var originPrefix: String?

	var isPopover: Bool { return popover?.arrowDirection != .unknown }
	weak var popover: UIPopoverPresentationController?

	var didSetup = false

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}

	func setup() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

		rewards = mission?.conversationRewards.flatRows() ?? []

		if isPopover {
			originHint = nil
		}

		setupOriginHint()

		setupTable()

		startListeners()

		didSetup = true
	}

	@IBAction func cancel(_ sender: AnyObject) {
		closeWindow()
	}

	func closeWindow() {
		presentingViewController?.dismiss(animated: true, completion: nil)
	}

	func setupTable() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(
			UINib(nibName: "ConversationRewardsDetailRow", bundle: bundle),
			forCellReuseIdentifier: "ConversationRewardsDetailRow"
		)
	}

	func saveConversationRewardsChoice(id: String, isOn: Bool) {
		guard let mission = mission else { return }
		if isOn {
			_ = mission.changed(conversationRewardId: id, isSelected: true, isSave: true)
		} else {
			_ = mission.changed(conversationRewardId: id, isSelected: false, isSave: true)
		}
	}

	internal func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(on: self) { [weak self] changed in
			if self?.mission?.id == changed.id,
				let newMission = changed.object ?? Mission.get(id: changed.id) {
				// We have to listen and change mission so that when save is called on each change, 
				// it is against the most recent copy of mission (otherwise only the last change is saved).
				self?.mission = newMission
				self?.rewards = newMission.conversationRewards.flatRows()
				DispatchQueue.main.async {
					self?.tableView.reloadData()
				}
			}
		}
	}

	internal func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Mission.onChange.cancelSubscription(for: self)
	}
}

extension ConversationRewardsDetailController { //: UITableViewDataSource {

	// MARK: Protocol - UITableViewDelegate

	override public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override public func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		return rewards.count
	}

	override public func tableView(
		_ tableView: UITableView,
		estimatedHeightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return 100
	}

	override public func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(
				withIdentifier: "ConversationRewardsDetailRow"
			) as? ConversationRewardsDetailRow {
			cell.define(data: rewards[(indexPath as NSIndexPath).row], parent: self)
			return cell
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
}

extension ConversationRewardsDetailController: OriginHintable {
	// var originHint: String? // already declared
	public func setupOriginHint() {
		originHintType.setupView()
	}
}
