//
//  MapController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/23/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
// TODO: Refactor

final public class MapController: UIViewController, UIScrollViewDelegate, MapImageSizable {
    let changeQueue = DispatchQueue(label: "MapController.data", qos: .background)

	enum VerticalDisclosureImage: String {
		case Closed = "Vertical Disclosure"
		case Open = "Vertical Disclosure (Open)"
	}

	var mapSplitViewController: MapSplitViewController? {
		return parent as? MapSplitViewController
	}

	public var map: Map? {
		get {
			return mapSplitViewController?.map
		}
		set {
			mapSplitViewController?.map = newValue
		}
	}
	var mapLocation: MapLocationable? {
		get {
			return mapSplitViewController?.mapLocation
		}
		set {
			mapSplitViewController?.mapLocation = newValue
		}
	}
	var segueMap: Map? {
		get {
			return mapSplitViewController?.segueMap
		}
		set {
			mapSplitViewController?.segueMap = newValue
		}
	}
	var explicitMapLocationable: MapLocationable?

	/// Cache for listening to changes.
	var shepardUuid = App.current.game?.shepard?.uuid

	@IBOutlet weak var baseView: UIView?
	@IBOutlet weak var breadcrumbsWrapper: UIView!
	@IBOutlet weak var breadcrumbsTextView: MarkupTextView!
	@IBOutlet weak var checkboxImageFiller: UIView?
	@IBOutlet weak var checkboxImageView: UIImageView?
	@IBAction func onClickCheckbox(_ sender: UIButton) {
		toggleCheckbox()
	}

	@IBOutlet weak var mapDetailsHeaderWrapper: UIStackView!
	@IBOutlet weak var mapDetailsWrapper: UIView!
	@IBOutlet weak var mapCalloutsWrapper: IBIncludedSubThing!
	@IBOutlet weak var mapCalloutsWrapperHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var verticalDisclosureWrapper: UIView!
	@IBOutlet weak var verticalDisclosureImageView: UIImageView?
	@IBAction func onClickDisclosure(_ sender: UIButton) {
	   toggleDetails()
	}

	public var originHint: String? {
		if let name = map?.name {
			return "Map: \(name)"
		}
		return nil
	}
	// Available
	@IBOutlet weak var availabilityView: TextDataRow?
	public var availabilityMessage: String?
	lazy var availabilityRowType: AvailabilityRowType = {
		return AvailabilityRowType(controller: self, view: self.availabilityView)
	}()
	// Describable
	@IBOutlet public weak var descriptionView: TextDataRow?
	lazy var descriptionType: DescriptionType = { return DescriptionType(controller: self, view: self.descriptionView) }()
	// Game Segments
	@IBOutlet weak var gameSegments: GameSegments?
	// MapImageSizable
	@IBOutlet public weak var mapImageScrollView: UIScrollView?
	public weak var mapImageScrollHeightConstraint: NSLayoutConstraint?
	public weak var mapImageWrapperView: UIView?
	public var lastMapImageName: String?
	// Notesable
	@IBOutlet weak var notesView: NotesView?
	public var notes: [Note] = []
	// OriginHintable
	@IBOutlet public weak var originHintView: TextDataRow?
	public var referringOriginHint: String? { return mapSplitViewController?.referringOriginHint }
	lazy var originHintType: OriginHintType = { return OriginHintType(controller: self, view: self.originHintView) }()
	// RelatedLinksable
	@IBOutlet public weak var relatedLinksView: RelatedLinksView?
	public var relatedLinks: [String] = []

	var mapLocationsList = MapLocationsList()
	weak var mapCalloutsHeightConstraint: NSLayoutConstraint?
	weak var singleTapGesture: UITapGestureRecognizer?
	var originalWindowPortraitSize: CGSize?
	var originalWindowLandscapeSize: CGSize?
	var isSizingImage = false
	var mapLocations: [MapLocationable] = []
	lazy var currentCallout = MapCalloutsBoxNib.loadNib()

	var isUpdating = false
	var isDataChanged = false
	var isNeedsSetupImageSizable = true
	var isCalloutPointsNeedSetup = false
	var isPageLoaded = false
	var isPageVisible = false

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	deinit {
		removeListeners()
	}

	override public func viewWillAppear(_ animated: Bool) {
		if isDataChanged {
			explicitMapLocationable = nil
			reloadDataOnChange(isIgnoreVisibility: true)
			isDataChanged = false
		}
		super.viewWillAppear(animated)
		if map?.isShowInList == true {
			App.current.addRecentlyViewedMap(mapId: map?.id)
		}
	}

	override public func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		isPageVisible = true
		if let _ = mapImageWrapperView,
			let mapLocation = explicitMapLocationable ?? mapLocation {
			openMapLocationable(mapLocation, isIgnoreAvailabilityRules: true)
		}
		isPageLoaded = true
	}

	override public func viewWillDisappear(_ animated: Bool) {
		isPageVisible = false
		super.viewWillDisappear(animated)
		resetSegueValues()
	}

	override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard !UIWindow.isInterfaceBuilder else { return }
		setupMapImageSizable()
//        if let _ = mapImageWrapperView {
//			resizeMapCalloutPoints()
//        }
	}

	@IBAction func gameChanged(_ sender: UISegmentedControl) {} // TODO: remove

	func setup() {
		isUpdating = true

		mapSplitViewController?.parent?.navigationItem.title = map?.mapType.windowTitle ?? "Map"

		mapLocation?.shownInMapId = map?.id

		// changed should not be necessary, but... it is
		if let map = self.map?.changed(gameVersion: App.current.gameVersion) {
            self.map = map

            if !UIWindow.isInterfaceBuilder {
                // load map locations
                let mapLocations: [MapLocationable] = map.getMapLocations()
                    // make sure they all register as being local to this page (used by signals)
                    .map { var m = $0; m.shownInMapId = map.id; return m }
                if map.isSplitMenu {
                    // not a real map: we don't want to show submissions or subitems
                    self.mapLocations = mapLocations.filter({ $0 is Map })
                } else if map.image == nil {
                    // we don't want to show submissions or subitems
                    // also, don't show map image callouts without a link if there is no map
                    self.mapLocations = mapLocations.filter({ $0.isOpensDetail })
                } else {
                    self.mapLocations = mapLocations
                }

                // update map location in case it changed version
                if let mapLocation = mapLocation,
                    let index = mapLocations.firstIndex(where: { $0.isEqual(mapLocation) }) {
                    self.mapLocation = mapLocations[index]
                    explicitMapLocationable = nil
                }
            }

			if !map.isMain {
				setupBreadcrumbs()

				if map.isExplorable {
					checkboxImageView?.superview?.isHidden = false
					checkboxImageFiller?.isHidden = true
					setCheckboxImage(isExplored: map.isExplored, isAvailable: map.isAvailable)
				} else {
					checkboxImageView?.superview?.isHidden = true
					checkboxImageFiller?.isHidden = false
				}

				setupDescription()

				setupGameSegments()

				setupNotes()

				setupRelatedLinks()

				setupMapDetails()

			} else {
				breadcrumbsWrapper.isHidden = true
				mapDetailsWrapper.isHidden = true
			}
		}

		setupAvailability()

		setupOriginHint()

		setupMapLocationsList()

		// ought to happen after image, after layout, but values will only be changed with data here.
		isCalloutPointsNeedSetup = true

		isUpdating = false

        setupEnhancedData()
	}

    func setupEnhancedData() {
        guard !UIWindow.isInterfaceBuilder,
              let map = self.map, !map.isSplitMenu && map.image != nil else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            let mapLocations: [MapLocationable] = MapLocation.addChildMapLocations(
                mapLocations: map.getMapLocations(),
                includeAllChildren: true
                ).map { var m = $0; m.shownInMapId = map.id; return m }
            self?.changeQueue.sync {
                DispatchQueue.main.async {
                        self?.mapLocations = mapLocations
                    _ = self?.mapLocationsList.add(locations: mapLocations)
                }
            }
        }
    }
}

// MARK: Map Image
extension MapController {

	func setupMapImageSizable() {
		if isNeedsSetupImageSizable {
			isNeedsSetupImageSizable = false
			mapImageScrollView?.delegate = self
			setupMapImage(baseView: baseView, competingView: mapDetailsHeaderWrapper)
			removeGestureRecognizers()
			addGestureRecognizers()
		} else {
			resizeMapImage(baseView: baseView, competingView: mapDetailsHeaderWrapper)
		}

		mapLocationsList.baseZoomScale = mapImageScrollView?.zoomScale ?? 1.0
		if isCalloutPointsNeedSetup {
			resizeAllMapLocations()
			mapLocationsList.zoomButtons(zoomScale: mapImageScrollView?.zoomScale ?? 1.0)
			isCalloutPointsNeedSetup = false
		}
	}
}

// MARK: Map Details
extension MapController {

	/// Only used when there is no image, and map details are visible by default
	func setupMapDetails() {
		let isCalloutsButtonVisible = map?.image != nil && !mapLocations.isEmpty
		let isInlineCalloutsVisible = map?.image == nil //&& !mapLocations.isEmpty
		let isToggleDetailsClosed = map?.image != nil

		if isCalloutsButtonVisible {
            parent?.parent?.navigationItem.rightBarButtonItem?.tintColor = MEGameTrackerColor.renegade
			parent?.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
		} else {
			parent?.parent?.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
			parent?.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
		}

		if isInlineCalloutsVisible {
			if let controller = mapCalloutsWrapper.includedController as? MapCalloutsGroupsController {
                controller.map = map
                controller.inheritedMapLocations = mapLocations
                controller.heightConstraint = mapCalloutsWrapperHeightConstraint
				controller.isDontScroll = true // use map page scroll instead
				controller.shouldSegueToCallout = true // normally we just show callout box, but no image = segue to callout
				controller.navigationPushController = self.navigationController // triggers setup
			}
		}

		mapCalloutsWrapper.isHidden = !isInlineCalloutsVisible
		mapDetailsWrapper.isHidden = isToggleDetailsClosed
		if isToggleDetailsClosed {
			// map image: hide all the text data, but allow it to be toggled visible
			verticalDisclosureWrapper.isHidden = false
			setDisclosureImage(isOpen: false)
		} else {
			// no map image: show all the text data
			verticalDisclosureWrapper.isHidden = true
			setDisclosureImage(isOpen: true)
		}

		mapImageWrapperView?.isHidden = map?.image == nil
	}
}

// MARK: Callout Box and Buttons
extension MapController {
	func setupMapLocationsList() {
		mapLocationsList.inMapId = map?.id
		mapLocationsList.inView = mapImageWrapperView
		let isSplitMenu = map?.isSplitMenu ?? false
		mapLocationsList.isSplitMenu = isSplitMenu
//        mapLocationsList.onClick = { [weak self] (button: MapLocationButtonNib) in
//            guard let location = self?.mapLocationsList.getLocations(fromButton: button).first else { return }
//
//            if isSplitMenu, let menuItemMap = location as? Map {
//                self?.segueToMap(menuItemMap)
//            } else {
//                MapLocation.onChangeSelection.fire((location))
//            }
//
//        }
		mapLocationsList.removeAll()
		_ = mapLocationsList.add(locations: mapLocations)
	}

	func resizeMapLocationable(_ mapLocation: MapLocationable) {
		guard let key = mapLocation.mapLocationPoint?.key,
			let mapImageWrapperView = self.mapImageWrapperView,
			let originalSize = map?.referenceSize  else { return }
		let actualSize = mapImageWrapperView.bounds.size
		mapLocationsList.resizeButton(atKey: key, fromSize: originalSize, toSize: actualSize)
		// refresh value reference
		if currentCallout?.calloutOrigin?.mapLocationPoint?.key == key,
			let button = mapLocationsList.buttons[key] {
			currentCallout?.calloutOrigin = button
		}
		// make sure it's been added to view
		if !isNeedsSetupImageSizable,
			let key = mapLocation.mapLocationPoint?.key,
			let button = mapLocationsList.buttons[key] {
			mapLocationsList.insert(button: button, inView: mapImageWrapperView)
		}
        mapImageWrapperView.layoutIfNeeded()
	}

	func resizeAllMapLocations() {
		guard let mapImageWrapperView = self.mapImageWrapperView,
			let originalSize = map?.referenceSize else { return }
		let actualSize = mapImageWrapperView.bounds.size
		mapLocationsList.resizeButtons(fromSize: originalSize, toSize: actualSize)
		// refresh value reference
		if currentCallout?.calloutOrigin != nil,
			let key = currentCallout?.calloutOrigin?.mapLocationPoint?.key,
			let button = mapLocationsList.buttons[key] {
			currentCallout?.calloutOrigin = button
		}
		// make sure they were added to view
		mapLocationsList.insertAll(inView: mapImageWrapperView)
        mapImageWrapperView.layoutIfNeeded()
	}

	func openMapLocationable(_ mapLocation: MapLocationable) {
		openMapLocationable(mapLocation, isIgnoreAvailabilityRules: true)
	}
	func openMapLocationable(_ mapLocation: MapLocationable, isIgnoreAvailabilityRules: Bool) {
		guard mapLocationsList.add(
			location: mapLocation,
			isIgnoreAvailabilityRules: isIgnoreAvailabilityRules
		)  else {
			return
		}
		resizeMapLocationable(mapLocation)
		explicitMapLocationable = mapLocation
		guard !isNeedsSetupImageSizable else { return } //&& isPageVisible else { return }
		if let point = mapLocation.mapLocationPoint,
			let button = mapLocationsList.getButton(atPoint: point) {
			showCalloutBox(forButton: button)
		}
	}

	func showCalloutBox(forButton button: MapLocationButtonNib) {
		guard let currentCallout = self.currentCallout,
			  map?.isSplitMenu == false else { return }
        button.superview?.layoutIfNeeded()
		currentCallout.calloutOrigin = button
		currentCallout.calloutOriginController = self
		currentCallout.mapLocations = mapLocationsList.getLocations(fromButton: button)
		currentCallout.explicitCallout = explicitMapLocationable
		currentCallout.zoomScale = mapImageScrollView?.zoomScale ?? 1.0
		if currentCallout.superview == nil {
			mapImageScrollView?.addSubview(currentCallout)
		} else {
			currentCallout.setup()
		}
	}

	func moveCalloutBox() {
		if currentCallout?.superview != nil {
			currentCallout?.zoomScale = mapImageScrollView?.zoomScale ?? 1.0
			currentCallout?.moveCalloutBox()
		}
	}

	func removeCalloutBox() {
		currentCallout?.removeFromSuperview()
		currentCallout?.calloutOrigin = nil
		explicitMapLocationable = nil
	}
}

// MARK: Reload data
extension MapController {

	func reloadMap() {
		if let mapId = self.map?.id,
		   let map = Map.get(id: mapId) {
			self.map = map
			isNeedsSetupImageSizable = true
			reloadDataOnChange()
		}
	}

	func reloadMapLocationable(_ mapLocation: MapLocationable) {
		// add/update location
		guard mapLocationsList.add(location: mapLocation) else { return }
		resizeMapLocationable(mapLocation)
	}

	func reloadDataOnChange(isIgnoreVisibility: Bool = false) {
		if !isIgnoreVisibility && !isPageVisible {
			// save changes for when page reloads
			isDataChanged = true
			return
		}
		DispatchQueue.main.async { [weak self] in
            self?.setup()
			self?.isCalloutPointsNeedSetup = true
			self?.setupMapImageSizable()
		}
	}
}

// MARK: Rotation Handler
extension MapController {

	override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		guard mapImageWrapperView != nil
		else {
			super.viewWillTransition(to: size, with: coordinator)
			return
		}
		currentCallout?.removeFromSuperview()
		coordinator.animate(alongsideTransition: { _ in
			self.setupMapImageSizable()
		}, completion: { _ in
			self.setupMapImageSizable() // doesn't seem to do it right in animator
			if let button = self.currentCallout?.calloutOrigin {
				self.showCalloutBox(forButton: button)
			}
		})
		super.viewWillTransition(to: size, with: coordinator)
	}

}

// MARK: UIGestureRecognizerDelegate
extension MapController: UIGestureRecognizerDelegate {

	func addGestureRecognizers() {
		let singleTap = UITapGestureRecognizer(target: self, action: #selector(MapController.tapMap(_:)))
		singleTap.numberOfTapsRequired = 1
		singleTap.delegate = self
		mapImageScrollView?.addGestureRecognizer(singleTap)
		singleTapGesture = singleTap
	}

	func removeGestureRecognizers() {
		if let singleTap = singleTapGesture {
			mapImageScrollView?.removeGestureRecognizer(singleTap)
			singleTapGesture = nil
		}
	}

	/// Delegate method.
	/// Ignore any callout button clicks - they are not tap gestures.
	public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if let callout = currentCallout, let view = touch.view,
			view.isDescendant(of: callout) {
			return false
		}
		return true
	}

	@objc func tapMap(_ sender: UITapGestureRecognizer) {
		if let button = mapLocationsList.getButtonTouched(gestureRecognizer: sender) {
			if let location = mapLocationsList.getLocations(fromButton: button).first {
				if map?.isSplitMenu == true, let menuItemMap = location as? Map {
					segueToMap(menuItemMap)
				} else {
					MapLocation.onChangeSelection.fire((location))
				}
			}
		} else {
			removeCalloutBox()
		}
	}
}

// MARK: UIScrollViewDelegate
extension MapController {

	public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return mapImageWrapperView
	}

	public func scrollViewDidZoom(_ scrollView: UIScrollView) {
		if let zoomScale = mapImageScrollView?.zoomScale {
			mapLocationsList.zoomButtons(zoomScale: zoomScale)
		}
		moveCalloutBox()
	}
}

// MARK: Segues
extension MapController {

	func resetSegueValues() {
		segueMap = nil
	}

	func segueToMap(_ map: Map) {
		startSpinner(inView: view)
		segueMap = map
		parent?.performSegue(withIdentifier: "Show Map", sender: nil)
		stopSpinner(inView: view)
	}

	func segueToMission(_ mission: Mission) {
		startSpinner(inView: view)
		let linkHandler = LinkHandler(controller: self)
		linkHandler.switchToLinkableTab(.missions,
			toControllerType: MissionsGroupsController.self
		) { controller in
			(controller as? MissionsGroupsController)?.deepLinkedMission = mission
			(controller as? DeepLinkable)?.deepLink(mission, type: "Mission")
		}
		stopSpinner(inView: view)
	}

//	func segueToItem(item: Item) {
//		view.userInteractionEnabled = false
//		let linkHandler = LinkHandler(source: self)
//		linkHandler.deepLinkFromTab(.Items, toControllerType: ItemsController.self, withObject: item)
//		view.userInteractionEnabled = true
//	}

	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			DispatchQueue.main.async {
				self.reloadMap()
			}
		}
	}
}

// MARK: Listeners
extension MapController {

    private func reloadOnLocationChange<T: GameRowStorable & DateModifiable & MapLocationable>(
        type: T.Type,
        changed: (id: String, object: T?)
    ) {
        guard let map = self.map else { return }// local copy to avoid view controller reference
        let mapLocations: [MapLocationable] = self.mapLocations // local copy to avoid view controller reference
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let index = mapLocations.firstIndex(where: { $0.id == changed.id }),
               let oldLocation = mapLocations[index] as? T,
               var newLocation: MapLocationable = changed.object ?? T.get(id: changed.id),
               newLocation.modifiedDate > oldLocation.modifiedDate {
                newLocation.shownInMapId = map.id // set this or callout may not appear in map
                if let parentMap = self?.findAncestorInCurrentMap(location: newLocation) {
                    // descendent map callout, set to ancestor location for clicking
                    newLocation.mapLocationPoint = parentMap.mapLocationPoint
                }
                self?.changeQueue.async { [weak self] in
                    DispatchQueue.main.sync { [weak self] in
                        if let index = self?.mapLocations.firstIndex(where: { $0.id == newLocation.id }) {
                            self?.mapLocations[index] = newLocation
                        }
                        if self?.explicitMapLocationable?.id == newLocation.id {
                            self?.explicitMapLocationable = newLocation
                        }
                        if self?.mapLocation?.id == newLocation.id {
                            self?.mapLocation = newLocation
                        }
                        self?.reloadMapLocationable(newLocation)
                    }
                }
            }
        }
    }
    
    private func findAncestorInCurrentMap(location: MapLocationable) -> MapLocationable? {
        if location.inMapId == map?.id {
            return location
        }
        
        if let parentId = location.inMapId,
           let parentMap = Map.get(id: parentId) {
            return findAncestorInCurrentMap(location: parentMap)
        }
        
        return nil
    }

	private func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(with: self) { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadOnShepardChange()
            }
        }
		// listen for changes to map location selected
		MapLocation.onChangeSelection.cancelSubscription(for: self)
		_ = MapLocation.onChangeSelection.subscribe(with: self) { [weak self] changed in
            DispatchQueue.main.async {
                self?.openMapLocationable(changed)
            }
        }
		// listen for changes to maps data 
		Map.onChange.cancelSubscription(for: self)
		_ = Map.onChange.subscribe(with: self) { [weak self] changed in
            DispatchQueue.main.async {
                guard let map = self?.map else { return }
                DispatchQueue.global(qos: .background).async { [weak self] in
                    if map.id == changed.id,
                        let newMap = changed.object ?? Map.get(id: changed.id) {
                        self?.changeQueue.async {
                            DispatchQueue.main.async {
                                self?.map = newMap
                                self?.reloadDataOnChange()
                            }
                        }
                    }
                }
//                guard changed.object == nil else { return } // filters to only events
                self?.reloadOnLocationChange(type: Map.self, changed: changed)
            }
		}
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(with: self) { [weak self] changed in
//            guard changed.object == nil else { return } // filters to only events
            DispatchQueue.main.async {
                self?.reloadOnLocationChange(type: Mission.self, changed: changed)
            }
		}
		Item.onChange.cancelSubscription(for: self)
		_ = Item.onChange.subscribe(with: self) { [weak self] changed in
//            guard changed.object == nil else { return } // filters to only events
            DispatchQueue.main.async {
                self?.reloadOnLocationChange(type: Item.self, changed: changed)
            }
		}
	}

	private func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		App.onCurrentShepardChange.cancelSubscription(for: self)
		MapLocation.onChangeSelection.cancelSubscription(for: self)
		Map.onChange.cancelSubscription(for: self)
		Mission.onChange.cancelSubscription(for: self)
		Item.onChange.cancelSubscription(for: self)
	}
}

// MARK: Actions
extension MapController {

	func didSaveNotes(_ notes: [Note]) {
		// nothing
	}

}

extension MapController {

	func toggleCheckbox() {
        guard let map = self.map else { return }
		let isExplored = !map.isExplored
		let spinnerController = self as Spinnerable?
		DispatchQueue.main.async {
			spinnerController?.startSpinner(inView: self.view)
            // make UI changes now
			self.setCheckboxImage(isExplored: isExplored, isAvailable: map.isAvailable)
			self.changeQueue.sync {
                // still inside main UI queue?
                // save changes to DB
                self.map = map.changed(isExplored: isExplored, isSave: true)
				spinnerController?.stopSpinner(inView: self.view)
			}
		}
	}

	func setCheckboxImage(isExplored: Bool, isAvailable: Bool) {
        checkboxImageView?.image = isExplored ? MapCheckbox.filled.getImage() : MapCheckbox.empty.getImage()
        if !isAvailable {
            checkboxImageView?.tintColor = MEGameTrackerColor.disabled
        } else {
            checkboxImageView?.tintColor = MEGameTrackerColor.renegade
        }
	}
}

extension MapController {

	func toggleDetails() {
		let isOpen = mapDetailsWrapper.isHidden // opposite of current state
		mapDetailsWrapper.isHidden = !isOpen
		setDisclosureImage(isOpen: isOpen)
		view.setNeedsLayout()
		view.layoutIfNeeded()
		setupMapImageSizable() // re-center
	}

	func setDisclosureImage(isOpen: Bool) {
		verticalDisclosureImageView?.image =  UIImage(
			named: isOpen ? VerticalDisclosureImage.Open.rawValue : VerticalDisclosureImage.Closed.rawValue
		)
	}

}

// MARK: Available
extension MapController: Available {
	//public var availabilityMessage: String? // already declared

	private func setupAvailability() {
		availabilityMessage = map?.unavailabilityMessages.joined(separator: ", ")
		availabilityRowType.setupView()
	}
}

// MARK: Breadcrumbs
extension MapController {
	private func setupBreadcrumbs() {
		guard let breadcrumbs = self.map?.getCompleteBreadcrumbs(),
			let map = self.map, !breadcrumbs.isEmpty else { return }
		let name = map.name
		breadcrumbsWrapper.isHidden = false
		var lastMapId = map.id
		var mapHierarchy: [String] = []
		breadcrumbs.reversed().forEach {
			mapHierarchy.insert($0.deepLinkString(mapLocationId: lastMapId, alwaysDeepLink: true), at: 0)
			lastMapId = $0.id
		}
		let mapHierarchyString = mapHierarchy.joined(separator: " > ")
		breadcrumbsTextView.text = "\(mapHierarchyString) > \(name)"
		breadcrumbsTextView.linkOriginController = self
	}
}

// MARK: Describable
extension MapController: Describable {
	public var descriptionMessage: String? {
		return map?.description
	}

	private func setupDescription() {
		descriptionType.setupView()
	}
}

// MARK: Game Segments
extension MapController {
	private func setupGameSegments() {
		var games: [GameVersion] = []
		for game in GameVersion.allCases {
			if map?.isAvailableInGame(game) == true {
				games.append(game)
			}
		}
		gameSegments?.games = games
	}
}

// MARK: Notesable
extension MapController: Notesable {
	//public var notesView: NotesView? // already declared
	//public var originHint: String? // already declared
	//public var notes: [Note] // already declared

	private func setupNotes() {
		map?.getNotes { [weak self] notes in
			DispatchQueue.main.async {
				self?.notes = notes
				self?.notesView?.controller = self
				self?.notesView?.setup()
			}
		}
	}

	public func getBlankNote() -> Note? {
		return map?.newNote()
	}
}

// MARK: OriginHintable
extension MapController: OriginHintable {
	//public var originHint: String? // already declared

	private func setupOriginHint() {
		if let referringOriginHint = self.referringOriginHint {
			originHintType.overrideOriginPrefix = "From"
			originHintType.overrideOriginHint = referringOriginHint
		} else {
			originHintType.overrideOriginHint = "" // block other origin hint
		}
		originHintType.setupView()
	}
}

// MARK: RelatedLinksable
extension MapController: RelatedLinksable {
	//public var relatedLinks: [String] // already declared

	private func setupRelatedLinks() {
		relatedLinks = map?.relatedLinks ?? []
		relatedLinksView?.controller = self
		relatedLinksView?.setup()
	}
}

extension MapController: Spinnerable {}

// swiftlint:enable file_length
