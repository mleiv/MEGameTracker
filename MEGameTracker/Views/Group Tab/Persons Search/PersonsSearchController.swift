//
//  PersonsSearchController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/29/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

class PersonsSearchController: UITableViewController, Spinnerable {

	@IBOutlet weak var tempSearchBar: UISearchBar!
	var searchController: UISearchController?
	var currentSearchText = ""

	var shepard: Shepard?
	var persons: [Person] = []

	var lastSearch = String("")
	var isUpdating = true

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard !UIWindow.isInterfaceBuilder else { return }
		searchController?.isActive = true
	}

	// MARK: Setup Page Elements

	func setup(isForceReloadData: Bool = false) {
		isUpdating = true
		defer {
			isUpdating = false
		}
		tableView.allowsMultipleSelectionDuringEditing = false
		setupTableCustomCells()
		if UIWindow.isInterfaceBuilder {
			fetchDummyData()
		} else {
			shepard = App.current.game?.shepard
		}
		setupSearchController()
		if isForceReloadData {
			tableView.reloadData()
		}
	}

	func fetchDummyData() {
		persons = [Person.getDummy(), Person.getDummy()].flatMap { $0 }
	}

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "PersonRow", bundle: bundle), forCellReuseIdentifier: "PersonRow")
	}

	func setupRow(_ row: Int, cell: PersonRow) {
		guard row < persons.count else { return }
		let id = persons[row].id
		cell.define(
			person: persons[row],
			isLoveInterest: persons[row].isLoveInterest,
			onChangeLoveSetting: { [weak self] (sender) in
				DispatchQueue.global(qos: .background).async {
					_ = self?.shepard?.changed(loveInterestId: sender.isOn ? id : nil)
				}
			}
		)
	}

	func reloadDataOnChange(_ x: Bool = false) {
		if let searchController = searchController {
			updateSearchResults(for: searchController)
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gender/romantic changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadDataOnChange)
		// listen for changes to persons data
		Person.onChange.cancelSubscription(for: self)
		_ = Person.onChange.subscribe(on: self) { [weak self] changed in
			if let index = self?.persons.index(where: { $0.id == changed.id }),
				let newPerson = changed.object ?? Person.get(id: changed.id) {
				self?.persons[index] = newPerson
				let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
				self?.reloadRows(reloadRows)
			}
		}
	}

}

extension PersonsSearchController {
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
		return UITableViewAutomaticDimension
	}

	override func tableView(
		_ tableView: UITableView,
		heightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	override func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		if (indexPath as NSIndexPath).row < persons.count {
			startSpinner(inView: view.superview)
			if let parentController = parent as? SearchGroupSplitViewController {
				let ferriedSegue: FerriedPrepareForSegueClosure = {
					(destinationController: UIViewController) in
					destinationController.find(controllerType: PersonController.self) { controller in
						controller.person = self.persons[(indexPath as NSIndexPath).row]
					}
				}
				parentController.performChangeableSegue("Show GroupFlow.Person", sender: nil, ferriedSegue: ferriedSegue)
			}
			stopSpinner(inView: view.superview)
		}
	}
}

extension PersonsSearchController: UpdatingTableView {
	// public func reloadRows(rows: [NSIndexPath]) // defined in protocol
}

extension PersonsSearchController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
	// MARK: Search

	func setupSearchController() {
		guard !UIWindow.isInterfaceBuilder else { return }

		definesPresentationContext = true // hold search to our current bounds

		// create search controller (no IB equivalent)
		let controller = UISearchController(searchResultsController: nil)
//        controller.hidesNavigationBarDuringPresentation = false
		controller.dimsBackgroundDuringPresentation = false
		controller.delegate = self
		controller.searchResultsUpdater = self
		controller.searchBar.delegate = self
		controller.searchBar.searchBarStyle = tempSearchBar.searchBarStyle
		controller.searchBar.placeholder = tempSearchBar.placeholder
		controller.searchBar.barTintColor = tempSearchBar.barTintColor
		// fix the black line:
		controller.searchBar.layer.borderWidth = CGFloat(1)/UIScreen.main.scale //1px
		controller.searchBar.layer.borderColor = UIColor.gray.cgColor
		// replace placeholder:
		controller.searchBar.setNeedsLayout()
		controller.searchBar.layoutIfNeeded()
		tableView.tableHeaderView = controller.searchBar
		searchController = controller
	}

	func searchPersons(_ search: String? = nil) {
		guard search?.isEmpty == false else {
			return
		}
		currentSearchText = search ?? ""
		if !UIWindow.isInterfaceBuilder, let search = search {
			DispatchQueue.global(qos: .background).async { [weak self] in
				self?.persons = Person.getAll(likeName: search).sorted(by: Person.sort)
				guard search == self?.currentSearchText else { return }
				DispatchQueue.main.async { [weak self] in
					guard search == self?.currentSearchText else { return }
					self?.searchController?.isActive = true
					self?.tableView.reloadData()
				}
			}
		}
	}

	// MARK: UISearchBarDelegate

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		if searchController?.isActive == true {
			searchController?.dismiss(animated: true) { () -> Void in }
			tableView.reloadData()
		}
	}

	// MARK: UISearchResultsUpdating

	func updateSearchResults(for searchController: UISearchController) {
		let search = searchController.searchBar.text?.trim() ?? ""
		if search.isEmpty && !(lastSearch.isEmpty) {
			lastSearch = search
			searchPersons()
		} else if !search.isEmpty && search != lastSearch {
			lastSearch = search
			searchPersons(search)
		}
		// else empty, do nothing
	}

	// MARK: UISearchControllerDelegate

	func didPresentSearchController(_ searchController: UISearchController) {
		searchController.searchBar.becomeFirstResponder()
	}
}
