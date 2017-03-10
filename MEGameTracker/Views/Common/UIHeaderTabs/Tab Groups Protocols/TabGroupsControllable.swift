//
//  TabGroups.swift
//
//  Created by Emily Ivie on 9/23/15.
//  Copyright © 2015 urdnot.

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

//

import UIKit

// implemented by tab groups top-level page
public protocol TabGroupsControllable: class,
	UIPageViewControllerDataSource, UIPageViewControllerDelegate {

	// implement in controller:
	var tabs: UIHeaderTabs! { get } // @IBOutlet
	var tabsContentWrapper: UIView! { get } // @IBOutlet
	var tabNames: [String] { get }
	func tabControllersInitializer(tabName: String) -> UIViewController?
	// only used internally:
	var tabsPageViewController: UIPageViewController? { get set }
	var tabControllers: [String: UIViewController] { get set }
	var tabCurrentIndex: Int { get set }
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController?
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController?
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	)

	// public, but require no additional code in implementing controller
	func setupTabs()
	func setTabTitles(_ tabTitles: [String])
	func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController?
	func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController?
	func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	)
	func switchToTab(_ controller: UIViewController)
}

extension TabGroupsControllable where Self: UIViewController {

	public func setupTabs() {
		setupTabPages()
		setupTabsPageControl()
		setupTabsPageViewController()
	}

	public func setTabTitles(_ tabTitles: [String]) {
		tabs.change(segmentTitles: tabTitles)
	}

	func selectNewTabIndex() -> Int {
		return 0
	}

	func setupTabPages() {
		for tabName in tabNames {
			let tabController = tabControllersInitializer(tabName: tabName) ?? UIViewController() // fill index no matter what
			tabControllers[tabName] = tabController
		}
	}

	func setupTabsPageControl() {
		tabs.setup(segmentTitles: tabNames, selectedSegmentIndex: tabCurrentIndex, onClick: { [weak self] index in
			let tabName = self?.tabNames[index] ?? ""
			if let tabController = self?.tabControllers[tabName] {
				self?.switchToTab(tabController)
			}
		})
	}

	func setupTabsPageViewController() {
		let currentIndex = tabCurrentIndex < tabNames.count ? tabCurrentIndex : 0
		guard let currentController = tabControllers[tabNames[currentIndex]]
		else {
			return
		}
		let tabsPageViewController = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil
		)
		tabsPageViewController.dataSource = self
		tabsPageViewController.delegate = self
		tabsPageViewController.setViewControllers([currentController],
			direction: .forward,
			animated: false,
			completion: nil
		)
		tabsPageViewController.willMove(toParentViewController: self)
		self.addChildViewController(tabsPageViewController)
		tabsPageViewController.didMove(toParentViewController: self)
		tabsContentWrapper.addSubview(tabsPageViewController.view)
		tabsPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		tabsPageViewController.view.leadingAnchor.constraint(equalTo: tabsContentWrapper.leadingAnchor)
			.isActive = true
		tabsPageViewController.view.trailingAnchor.constraint(equalTo: tabsContentWrapper.trailingAnchor)
			.isActive = true
		tabsPageViewController.view.topAnchor.constraint(equalTo: tabsContentWrapper.topAnchor)
			.isActive = true
		tabsPageViewController.view.bottomAnchor.constraint(equalTo: tabsContentWrapper.bottomAnchor)
			.isActive = true
		self.tabsPageViewController = tabsPageViewController
	}

	public func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {

		if let tabName = tabControllers.keys.filter(({ self.tabControllers[$0] === viewController})).first,
			let index = tabNames.index(of: tabName) {
			tabCurrentIndex = index
			let prevIndex = tabCurrentIndex - 1
			if 0..<tabControllers.count ~= prevIndex {
				let prevController = tabControllers[tabNames[prevIndex]]
				return prevController
			}
		}
		return nil
	}

	public func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {

		if let tabName = tabControllers.keys.filter(({ self.tabControllers[$0] === viewController})).first,
			let index = tabNames.index(of: tabName) {
			tabCurrentIndex = index
			let nextIndex = tabCurrentIndex + 1
			if 0..<tabControllers.count ~= nextIndex {
				let nextController = tabControllers[tabNames[nextIndex]]
				return nextController
			}
		}
		return nil
	}

	public func handleTabsPageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {

		if completed, let
			controller = pageViewController.viewControllers?.last,
			let tabName = tabControllers.keys.filter(({ self.tabControllers[$0] === controller})).first,
			let index = tabNames.index(of: tabName) {
			tabCurrentIndex = index
			tabs.change(selectedSegmentIndex: tabCurrentIndex)
		}
	}

	public func switchToTab(_ controller: UIViewController) {
		var direction = UIPageViewControllerNavigationDirection.forward
		if let tabName = tabControllers.keys.filter(({ self.tabControllers[$0] === controller})).first,
			let index = tabNames.index(of: tabName) {
			guard index != tabCurrentIndex else { return }
			direction = index > tabCurrentIndex ? .forward : .reverse
			tabCurrentIndex = index
			tabs.change(selectedSegmentIndex: tabCurrentIndex)
		}
		tabsPageViewController?.setViewControllers([controller], direction: direction, animated: true, completion: nil)
	}
}
