//
//  PersonsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

class PersonsController: UITableViewController, Spinnerable {

	// set by page controller parent
	var persons: [Person] = []
	var tabsController: UIViewController?

	var isUpdating = true

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	// MARK: Setup Page Elements

	func setup(isForceReloadData: Bool = false) {
		isUpdating = true
		tableView.allowsMultipleSelectionDuringEditing = false
		setupTableCustomCells()
		setupPeople()
		if isForceReloadData {
			tableView.reloadData()
		}
		isUpdating = false
	}

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "PersonRow", bundle: bundle), forCellReuseIdentifier: "PersonRow")
	}

	// MARK: Table Data

	func dummyData() {
		persons = []
		// swiftlint:disable line_length
		let person1 = Person.getDummy(json: "{\"id\": 2,\"name\": \"Liara T'soni\",\"description\": \"An archeologist specializing in the ancient prothean culture, Liara is the \\\"pureblood\\\" daughter of Matriarch Benezia, and doesn't know her father. At 106 - young for an asari - she has eschewed the typical frivolities of youth and instead pursued a life of scholarly solitude.\",\"personType\": \"Squad\",\"isMaleLoveInterest\": true,\"isFemaleLoveInterest\": true,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"photo\": \"Default Liara\",\"gameVersion\": true,\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Liara_T%27Soni\\\"]\",\"voiceActor\": \"Ali Hillis\"}")
		let person2 = Person.getDummy(json: "{\"id\": 8,\"name\": \"David Anderson\",\"description\": \"The previous commander of the Normandy, Anderson is a mentor and friend of Shepard. He has a bad history with Saren, who prevented him from being promoted to Spectre himself many years ago. He remains on the Citadel after Eden Prime and provides Shepard with information and advice.\",\"personType\": \"Squad\",\"isMaleLoveInterest\": false,\"isFemaleLoveInterest\": false,\"race\": \"Human\",\"profession\": \"Captain\",\"organization\": \"Alliance\",\"photo\": \"Default Anderson\",\"gameVersion\": true,\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/David_Anderson\\\"]\",\"voiceActor\": \"Keith David Patrick Seitz\"}")
		persons = [person1, person2].compactMap { $0 }
		// swiftlint:enable line_length
	}

	func setupPeople() {
	}

	func setupRow(_ row: Int, cell: PersonRow) {
		if row < persons.count {
			cell.define(
				person: persons[row],
				isLoveInterest: persons[row].isLoveInterest,
				onChangeLoveSetting: { _ in
					DispatchQueue.global(qos: .background).async {
						if let id = self.persons[row].loveInterestDecisionId {
							_ = Decision.get(id: id)?.changed(isSelected: cell.isLoveInterest, isSave: true)
						}
					}
				}
			)
		}
	}

	/// Updates table rows with any custom data to person (like photo)
	func updatePersonOnChange(_ person: Person) {
		guard !isUpdating else { return }
		if let index = persons.index(of: person) {
			persons[index] = person
		}
		isUpdating = true
		tableView.reloadData()
		isUpdating = false
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for decision changes
//		Decision.onChange.cancelSubscription(for: self)
//		_ = Decision.onChange.subscribe(on: self) { [weak self] changed in
//			if let index = self?.persons.index(where: { $0.loveInterestDecisionId == changed.id }) {
//				let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
//				self?.reloadRows(reloadRows)
//			}

//		}
	}

	// MARK: Actions

	// MARK: Protocol - UITableViewDelegate

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		return persons.count
	}

//	override func tableView(
//		  tableView: UITableView,
//		  heightForHeaderInSection section: Int
//	  ) -> CGFloat {
//		return 1
//	}

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "PersonRow") as? PersonRow {
			setupRow((indexPath as NSIndexPath).row, cell: cell)
			return cell
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}

	override func tableView(
		_ tableView: UITableView,
		estimatedHeightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableView.automaticDimension
	}
	override func tableView(
		_ tableView: UITableView,
		heightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if (indexPath as NSIndexPath).row < persons.count {
			startSpinner(inView: view.superview)
			if let parentController = tabsController?.parent as? GroupSplitViewController {
				let ferriedSegue: FerriedPrepareForSegueClosure = { destinationController in
					destinationController.find(controllerType: PersonController.self) { controller in
						controller.person = self.persons[(indexPath as NSIndexPath).row]
					}
				}
				parentController.performChangeableSegue("Show GroupFlow.Person", sender: nil, ferriedSegue: ferriedSegue)
			}
			stopSpinner(inView: view.superview, isRemoveFromView: true)
		}
	}

	// custom for DeepLinkable
	func selectPerson(_ person: Person) {
		if let index = persons.index(of: person) {
			tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .top)
		}
		startSpinner(inView: view.superview)
		if let parentController = tabsController?.parent as? GroupSplitViewController {
			let ferriedSegue: FerriedPrepareForSegueClosure = { destinationController in
				destinationController.find(controllerType: PersonController.self) { controller in
					controller.person = person
				}
			}
			parentController.performChangeableSegue("Show GroupFlow.Person", sender: nil, ferriedSegue: ferriedSegue)
		}
		stopSpinner(inView: view.superview, isRemoveFromView: true)
	}
}

extension PersonsController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}
