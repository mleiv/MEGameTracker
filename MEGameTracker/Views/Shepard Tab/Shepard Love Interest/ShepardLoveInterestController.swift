//
//  ShepardLoveInterestController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/7/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

class ShepardLoveInterestController: UITableViewController, Spinnerable {

	var persons: [Person] = []

	var isUpdating = true

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	// MARK: Setup Page Elements

	func setup(reloadData: Bool = false) {
		isUpdating = true
		tableView.allowsMultipleSelectionDuringEditing = false
		setupTableCustomCells()
		fetchData()
		isUpdating = false
	}

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "PersonRow", bundle: bundle), forCellReuseIdentifier: "PersonRow")
	}

	func fetchData() {
		if UIWindow.isInterfaceBuilder {
            persons = [Person.getDummy(), Person.getDummy()].compactMap { $0 }
        } else {
            let shepard = App.current.game?.shepard
            let gameVersion = shepard?.gameVersion ?? .game1
            persons = Person.getAllLoveOptions(
                    gameVersion: gameVersion,
                    isMale: shepard?.gender == .male
                ).sorted(by: Person.sort)
        }
	}

	func setupRow(_ row: Int, cell: PersonRow) {
		guard row < persons.count else { return }
		cell.define(
			person: persons[row],
			isLoveInterest: persons[row].isLoveInterest,
			hideDisclosure: true,
			onChangeLoveSetting: { _ in
				DispatchQueue.global(qos: .background).async {
					if let id = self.persons[row].loveInterestDecisionId {
						_ = Decision.get(id: id)?.changed(isSelected: cell.isLoveInterest, isSave: true)
					}
				}
			}
		)
	}

	func reloadDataOnChange(_ x: Bool = false) {
		guard !isUpdating else { return }
		isUpdating = true
        fetchData()
        tableView.reloadData()
        isUpdating = false
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gender and game version changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(with: self) { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadDataOnChange()
            }
        }
		// listen for decision changes
		Decision.onChange.cancelSubscription(for: self)
		_ = Decision.onChange.subscribe(with: self) { [weak self] changed in
            DispatchQueue.main.async {
                if let index = self?.persons.firstIndex(where: { $0.loveInterestDecisionId == changed.id }) {
                    let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
                    self?.reloadRows(reloadRows)
                }
			}
		}
		// listen for changes to persons data
		Person.onChange.cancelSubscription(for: self)
		_ = Person.onChange.subscribe(with: self) { [weak self] changed in
			if self?.persons.contains(where: { $0.id == changed.id }) ?? false,
				let newPerson = changed.object ?? Person.get(id: changed.id) {
                DispatchQueue.main.async {
                    if let index = self?.persons.firstIndex(where: { $0.id == newPerson.id }) {
                        self?.persons[index] = newPerson
                        let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
                        self?.reloadRows(reloadRows)
                    }
                }
			}
		}
	}

}

extension ShepardLoveInterestController {
	// MARK: Protocol - UITableViewDelegate

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return persons.count
	}

//	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return 1
//	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRow") as? PersonRow {
			setupRow((indexPath as NSIndexPath).row, cell: cell)
			return cell
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

extension ShepardLoveInterestController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}
