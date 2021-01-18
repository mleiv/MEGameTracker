//
//  MissionGroupsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class MapCalloutsGroupsController: UIViewController, TabGroupsControllable {
    let changeQueue = DispatchQueue(label: "MapCalloutsGroupsController.data", qos: .background)

	public var map: Map?
	public var mapLocation: MapLocationable?

	public var isDontScroll = false
	public var shouldSegueToCallout = false

	/// Special property with listener - always set last.
	public var navigationPushController: UINavigationController? {
		didSet {
			if navigationPushController != oldValue {
				// values obtained: initialize page:
				isValuesInitialized = true
				if isViewDidLoadCalled {
					viewAndValuesDidLoad()
				}
			}
		}
	}

	public var inheritedMapLocations: [MapLocationable]?
	public var mapLocations: [MapLocationType: [MapLocationable]] = [:]
	var mapLocationsCounts: [MapLocationType: Int] = [:]
	var tabTitles: [String] = []

	var heightConstraint: NSLayoutConstraint?
	var onClick: ((MapLocationable) -> Void)?

	var isValuesInitialized = false
	var isViewDidLoadCalled = false
	var isHeightNeedsSetting = false
	var pageLoaded = false
	var isUpdating = false

	override public func viewDidLoad() {
		super.viewDidLoad()
		if isValuesInitialized {
			viewAndValuesDidLoad()
		}
		isViewDidLoadCalled = true
	}

	func viewAndValuesDidLoad() {
		setupPages()
		toggleListeners()
	}

	deinit {
		removeListeners()
	}

	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let mapLocation = self.mapLocation,
			let controller = tabControllers[mapLocation.mapLocationType.headingValue] {
			switchToTab(controller)
		}
		if isHeightNeedsSetting {
			// force it to resize
			heightConstraint?.constant = 100.0
		}
        view.layoutIfNeeded()
	}

	override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		// has to happen after viewWillAppear?
		if view.traitCollection.horizontalSizeClass == .compact, let name = map?.name {
			parent?.navigationItem.title = "\(name) Callouts"
		}
		resetHeights()
	}

	func setupPages() {
		isUpdating = true
		setupMapLocations()
		if !pageLoaded {
			setupTabs()
		} else {
			setAllControllerData()
		}
		setupMapLocationsCounts()
		setTabTitles(tabTitles)
		isUpdating = false
		pageLoaded = true
	}

	public func resetHeights() {
		guard (tabs?.bounds.height ?? 0) > 0 else {
			// we aren't visible yet
			isHeightNeedsSetting = true
			return
		}
		isHeightNeedsSetting = false
		let emptyTableRowHeight = CGFloat(40.0)
		var maxHeight = CGFloat(0.0)
		for (_, controller) in tabControllers {
            guard let calloutsController = controller as? MapCalloutsController else { continue }
            let height = calloutsController.estimatedHeight
            if height == 0 && calloutsController.callouts.count > 0 {
                calloutsController.calloutsView?.setNeedsLayout()
                calloutsController.calloutsView?.layoutIfNeeded()
            }
			maxHeight = max(maxHeight, height)
		}
		let height =  max(emptyTableRowHeight, maxHeight) + (tabs?.bounds.height ?? 0)
		heightConstraint?.constant = max(height, view.bounds.height) // never be smaller than self
	}

	func setupMapLocations() {
		if let map = self.map {
			// load all map locations on this map
			mapLocations = [:]
			for type in MapLocationType.allCases {
				mapLocations[type] = []
			}
			if !UIWindow.isInterfaceBuilder {
				let baseMapLocations = inheritedMapLocations ?? map.getMapLocations()
				var allMapLocations = baseMapLocations
				if inheritedMapLocations == nil {
					if map.isSplitMenu == true {
						// we don't want to show submissions or subitems
					} else if map.image == nil {
						// we don't want to show submissions or subitems
						// also, don't show map image callouts without a link if there is no map
						allMapLocations = allMapLocations.filter({ $0.isOpensDetail })
					}
				}
				for type in MapLocationType.allCases {
					mapLocations[type] = allMapLocations.filter({
						$0.mapLocationType == type
					}).sorted(by: MapLocation.sort).map({
						var mapLocation = $0
						mapLocation.shownInMapId = self.map?.id
						return mapLocation
					})
				}
			}
		}
		for type in MapLocationType.allCases where !(mapLocations[type] ?? []).isEmpty {
			tabCurrentIndex = type.intValue ?? 0
			break
		}

        setupEnhancedData()
	}

    func setupEnhancedData() {
        guard !UIWindow.isInterfaceBuilder,
            let map = map, !map.isSplitMenu && map.image != nil else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let mapLocations: [MapLocationable] = MapLocation.addChildMapLocations(
                mapLocations: map.getMapLocations(),
                includeAllChildren: true
                ).map { var m = $0; m.shownInMapId = map.id; return m }
            self?.changeQueue.sync {
                for type in MapLocationType.allCases {
                    self?.mapLocations[type] = mapLocations.filter({
                        $0.mapLocationType == type
                    }).sorted(by: MapLocation.sort)
                }
                DispatchQueue.main.async {
                    self?.setAllControllerData()
                    self?.setupMapLocationsCounts()
                    self?.setTabTitles(self?.tabTitles ?? [])
                }
            }
        }
    }

	func isFinishedCallout(_ mapLocation: MapLocationable) -> Bool {
		if let mission = mapLocation as? Mission {
			return mission.isCompleted
		}
		if let item = mapLocation as? Item {
			return item.isAcquired
		}
		return false
	}

	func setupMapLocationsCounts() {
		// add count to each visible tab
		tabTitles = []
		for type in MapLocationType.allCases {
			let name = type.headingValue
			let count = (mapLocations[type] ?? []).reduce(0) { $0 + (self.isFinishedCallout($1) ? 0 : 1) }
			mapLocationsCounts[type] = count
			tabTitles.append("\(name) (\(count))")
		}
	}

	func setAllControllerData() {
		for tabName in tabNames {
			setControllerData(controller: tabControllers[tabName], forTab: tabName)
			(tabControllers[tabName] as? MapCalloutsController)?.setupCallouts(isForceReloadData: true)
		}
	}

	func setControllerData(controller: UIViewController?, forTab tabName: String) {
		guard let controller = controller as? MapCalloutsController else { return }
		if let tabIndex = tabNames.firstIndex(of: tabName) {
			let type = MapLocationType.allCases[tabIndex]
			controller.callouts = mapLocations[type] ?? []
		} else {
			controller.callouts = []
		}
	}

	func reloadDataOnChange() {
		guard !isUpdating else { return }
		DispatchQueue.main.async {
			self.setupPages()
		}
	}

	func reloadMapLocationRows(_ reloadRows: [IndexPath], inTabType type: MapLocationType) {
		if let controller = tabControllers[type.headingValue] as? MapCalloutsController {
			controller.callouts = mapLocations[type] ?? []
            controller.reloadRows(reloadRows)
            changeQueue.sync {
                self.reloadMapLocationsCountForType(type)
            }
		}
	}

	func reloadMapLocationsCountForType(_ type: MapLocationType) {
		let count = (mapLocations[type] ?? []).reduce(0) { $0 + (self.isFinishedCallout($1) ? 0 : 1) }
		if count != mapLocationsCounts[type] {
			mapLocationsCounts[type] = count
			tabTitles = []
			for type in MapLocationType.allCases {
				let name = type.headingValue
				tabTitles.append("\(name) (\(mapLocationsCounts[type] ?? 0))")
			}
			setTabTitles(tabTitles)
		}
	}

	var shepardUuid = App.current.game?.shepard?.uuid
	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			reloadDataOnChange()
		}
	}

	func toggleListeners() {
		if inheritedMapLocations == nil {
			startListeners()
		} else {
			removeListeners()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		//listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(with: self) { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadOnShepardChange()
            }
        }
		// check just for tab switches
		MapLocation.onChangeSelection.cancelSubscription(for: self)
		_ = MapLocation.onChangeSelection.subscribe(with: self) { [weak self] mapLocation in
            DispatchQueue.main.async {
                guard let controller = self?.tabControllers[mapLocation.mapLocationType.headingValue] else { return }
                guard mapLocation.shownInMapId == self?.map?.id else { return }
                self?.switchToTab(controller)
            }
		}
	}

	func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		App.onCurrentShepardChange.cancelSubscription(for: self)
		MapLocation.onChangeSelection.cancelSubscription(for: self)
	}

	// MARK: TabGroupsControllable protocol

	@IBOutlet weak public var tabs: UIHeaderTabs!
	@IBOutlet weak public var tabsContentWrapper: UIView!

	public var tabNames: [String] = MapLocationType.allCases.map { $0.headingValue }

	public func tabControllersInitializer(tabName: String) -> UIViewController? {
		let bundle = Bundle(for: type(of: self))
		guard let controller = UIStoryboard(name: "MapCallouts", bundle: bundle)
			.instantiateInitialViewController() as? MapCalloutsController
		else {
			return nil
		}
		controller.tabGroupController = self
		setControllerData(controller: controller, forTab: tabName)
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

	func closeCallouts() {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
			(self.parent as? MapsFlowController)?.closeCallouts(nil)
		}
	}
}
