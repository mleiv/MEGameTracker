//
//  PersonGroupsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/8/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class PersonsGroupsController: UIViewController, Spinnerable, TabGroupsControllable {

	var persons: [PersonType: [Person]] = [:]
	var personsCounts: [PersonType: Int] = [:]
	var tabTitles: [String] = []

	var deepLinkedPerson: Person?

	var isLoaded = false
	var isUpdating = false

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	func setup() {
		isUpdating = true
		fetchData()
		if !isLoaded {
			setupTabs()
			setTabTitles(PersonType.categories().map { $0.headingValue })
		} else {
			setAllControllerData()
		}
		isUpdating = false
		isLoaded = true
	}

	func fetchData() {
		persons = [:]
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		persons[.squad] = Person.getAllTeam().sorted(by: Person.sort)
		persons[.associate] = Person.getAllAssociates().sorted(by: Person.sort)
		persons[.enemy] = Person.getAllEnemies().sorted(by: Person.sort)
	}

	func fetchDummyData() {
		persons[.squad] = [Person.getDummy(), Person.getDummy()].compactMap { $0 }
		persons[.associate] = []
		persons[.enemy] = []
	}

	func setAllControllerData() {
		for tabName in tabNames {
			setControllerData(controller: tabControllers[tabName], forTab: tabName)
			(tabControllers[tabName] as? PersonsController)?.setup(isForceReloadData: true)
		}
	}

	func setControllerData(controller: UIViewController?, forTab tabName: String) {
		guard let controller = controller as? PersonsController else { return }
		if let tabIndex = tabNames.firstIndex(of: tabName) {
			let type = PersonType.categories()[tabIndex]
			controller.persons = persons[type] ?? []
		} else {
			controller.persons = []
		}
	}

	func reloadPersonRows(_ reloadRows: [IndexPath], inTabType type: PersonType) {
		if let controller = tabControllers[type.headingValue] as? PersonsController {
			controller.persons = persons[type] ?? []
			controller.reloadRows(reloadRows)
//			reloadPersonCountForType(type)
		}
	}

	func reloadPersonCountForType(_ type: PersonType) {
		let count = persons[type]?.count ?? 0
		if count != personsCounts[type] {
			personsCounts[type] = count
			tabTitles = []
			for type in PersonType.categories() {
				let name = type.headingValue
				tabTitles.append("\(name) (\(personsCounts[type] ?? 0))")
			}
			setTabTitles(tabTitles)
		}
	}

	func reloadDataOnChange(_ x: Bool = false) {
		// we care about gender changes as well as game changes
		guard !UIWindow.isInterfaceBuilder else { return }
		DispatchQueue.main.async {
			self.setup()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(with: self, callback: reloadDataOnChange)
		// listen for changes to persons data
		Person.onChange.cancelSubscription(for: self)
		_ = Person.onChange.subscribe(with: self) { [weak self] changed in
			for type in (self?.persons ?? [:]).keys {
				if let index = self?.persons[type]?.firstIndex(where: { $0.id == changed.id }),
					let newPerson = changed.object ?? Person.get(id: changed.id) {
					self?.persons[type]?[index] = newPerson
					let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
					self?.reloadPersonRows(reloadRows, inTabType: type)
					break
				}
			}
		}
		Decision.onChange.cancelSubscription(for: self)
		_ = Decision.onChange.subscribe(with: self) { [weak self] changed in
			if let decision = changed.object, decision.loveInterestId == nil {
				return
			}
			for type in (self?.persons ?? [:]).keys {
				if let index = self?.persons[type]?.firstIndex(where: { $0.loveInterestDecisionId == changed.id }) {
					if let personId = self?.persons[type]?[index].id,
						let newPerson = Person.get(id: personId) {
						self?.persons[type]?[index] = newPerson
						let reloadRows: [IndexPath] = [IndexPath(row: index, section: 0)]
						self?.reloadPersonRows(reloadRows, inTabType: type)
					}
					break
				}
			}
		}
		// decisions are loaded at detail page, don't have to listen
	}

	// MARK: TabGroupsControllable protocol

	@IBOutlet weak public var tabs: UIHeaderTabs!
	@IBOutlet weak public var tabsContentWrapper: UIView!

	public var tabNames: [String] = PersonType.categories().map { $0.headingValue }
	public func tabControllersInitializer(tabName: String) -> UIViewController? {
		let bundle = Bundle(for: type(of: self))
		let controller = UIStoryboard(name: "Persons", bundle: bundle)
			.instantiateInitialViewController() as? PersonsController
		setControllerData(controller: controller, forTab: tabName)
		controller?.tabsController = self
		return controller
	}

	// only used internally:
	public var tabsPageViewController: UIPageViewController?
	public var tabControllers: [String: UIViewController] = [:]
	public var tabCurrentIndex = 0

	public func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		return handleTabsPageViewController(pageViewController, viewControllerBefore: viewController)
	}
	public func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		return handleTabsPageViewController(pageViewController, viewControllerAfter: viewController)
	}
	public func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		handleTabsPageViewController(pageViewController,
			didFinishAnimating: finished,
			previousViewControllers: previousViewControllers,
			transitionCompleted: completed
		)
	}

	// MARK: Actions

	func selectPerson(_ person: Person?) -> Bool {
		guard let person = person, view != nil else { return false }
		let index: Int = {
			return tabNames.firstIndex(of: person.personType.headingValue) ?? 0
		}()
		if tabNames.indices.contains(index) == true,
		   let listController = tabControllers[tabNames[index]] {
			DispatchQueue.main.async { [weak self] in
				self?.startSpinner(inView: self?.view)
				self?.switchToTab(listController)
				if let controller = listController as? PersonsController {
					controller.selectPerson(person)
				}
				self?.stopSpinner(inView: self?.view)
			}
			return true
		}
		return false
	}
}

extension PersonsGroupsController: DeepLinkable {

	public func deepLink(_ object: DeepLinkType?, type: String? = nil) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			if let person = object as? Person {
				if self?.selectPerson(person) == true {
					self?.deepLinkedPerson = nil
				} else {
					self?.deepLinkedPerson = person // wait
				}
			}
		}
	}
}
