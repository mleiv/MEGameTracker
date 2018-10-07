//
//  ShepardAppearanceController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/18/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class ShepardAppearanceController: UIViewController,
	UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

// MARK: Constants

	let convertAlert = "This conversion may be flawed. See more notes on the sliders below."
	let convertNotice = "This conversion is approximate. See more notes on the sliders below."

// MARK: Outlets

	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var ME23GameSegment: UISegmentedControl!
	@IBOutlet weak var ME2CodeField: UITextField!
	@IBOutlet weak var ME2CodeLabel: UILabel!
	@IBOutlet weak var ME2NoticeLabel: UILabel!
	@IBOutlet weak var ME2AlertLabel: UILabel!
	@IBOutlet weak var ME2Button: UIButton!
	@IBOutlet weak var attributesTableView: UITableView!
	@IBOutlet weak var attributesTableViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ME1Button: UIButton!
	@IBOutlet weak var scanCodeButton: UIButton?

	@IBAction func scanCodeAction(_ sender: UIButton) { openScanCode() }
// MARK: Variables

	var shepard: Shepard?

	var currentGame: GameVersion?
	var currentGame1Attributes: [Shepard.Appearance.AttributeType : Int] = [:]

	var currentAppearance: Shepard.Appearance { return shepard?.appearance ?? Shepard.Appearance(gameVersion: .game1) }
	var currentGender: Shepard.Gender { return shepard?.gender ?? .male }

	var pendingAppearanceGame1: Shepard.Appearance?
	var pendingAppearanceGame2: Shepard.Appearance?
	var pendingAppearanceGame3: Shepard.Appearance?

	var sortedGroups: [Shepard.Appearance.GroupType] = []

	var game23SliderChoice = GameVersion.game2 // set by slider

	var defaultScrollOffset: CGPoint?
	var defaultScrollInset: UIEdgeInsets?
	var oldAttributesTableViewHeight: CGFloat?

	private var lastCode: String?
	var didSetup = false

	// MARK: Page Events

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		startSpinner(inView: view)
		setupTableCustomCells()
		attributesTableView.delegate = self
		attributesTableView.dataSource = self
		setup()
		stopSpinner(inView: view)
		startListeners()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// it does not layout table/view correctly earlier than this
		// in fact, trying to do this earlier stops it from using table height constraint at all.
		sizeAttributesTableView(relayout: true)
		defaultScrollOffset = scrollView.contentOffset
		defaultScrollInset = scrollView.contentInset
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		sizeAttributesTableView()
	}

	// MARK: Actions
	@IBAction func ME2CodeSelected(_ sender: UITextField) {
		if Shepard.Appearance.Format.isEmpty(ME2CodeField.text ?? "") {
			ME2CodeField.text = ""
		}
	}

	@IBAction func ME2CodeChanged(_ sender: UITextField) {
		// TODO: format code
		ME2CodeLabel.text = ME2CodeField.text
		// save any changes to other 2/3 game:
		var appearance = Shepard.Appearance(ME2CodeField.text?.uppercased()
			?? "", fromGame: game23SliderChoice, withGender: currentGender)
		if game23SliderChoice == .game2 {
			appearance.convert(toGame: .game3)
			pendingAppearanceGame3 = appearance
		} else {
			appearance.convert(toGame: .game2)
			pendingAppearanceGame2 = appearance
		}
	}

	@IBAction func ME2CodeSubmit(_ sender: AnyObject) {
		startSpinner(inView: view)
		var appearance = Shepard.Appearance(ME2CodeField.text?.uppercased()
			?? "", fromGame: game23SliderChoice, withGender: currentGender)
		appearance.convert(toGame: .game1)
		pendingAppearanceGame1 = appearance
		currentGame1Attributes = pendingAppearanceGame1?.contents ?? [:]
		setup()
		attributesTableView.reloadData()
		sizeAttributesTableView(relayout: true)
		stopSpinner(inView: view)
	}

	@IBAction func ME1SlidersSubmit(_ sender: AnyObject) {
		startSpinner(inView: view)
		for (attribute, value) in currentGame1Attributes {
			currentGame1Attributes[attribute] = value > 0 ? value : 1
		}
		var newAppearance1 = Shepard.Appearance("", fromGame: .game1, withGender: currentGender)
		newAppearance1.contents = currentGame1Attributes
		pendingAppearanceGame1 = newAppearance1
		// save to both game 2 and game 3
		var newAppearance2 = newAppearance1
		newAppearance2.convert(toGame: .game2)
		pendingAppearanceGame2 = newAppearance2
		var newAppearance3 = newAppearance1
		newAppearance3.convert(toGame: .game2)
		pendingAppearanceGame3 = newAppearance3
		save()
		ME2CodeField.text = game23SliderChoice == .game2 ? newAppearance2.format() : newAppearance3.format()
		ME2CodeLabel.text = ME2CodeField.text
		scrollView.contentOffset = defaultScrollOffset ?? scrollView.contentOffset
		scrollView.contentInset = defaultScrollInset ?? scrollView.contentInset
		stopSpinner(inView: view)
	}

	@IBAction func game23Changed(_ sender: AnyObject) {
		game23SliderChoice = sender.selectedSegmentIndex == 0 ? .game2 : .game3
		currentGame = game23SliderChoice
		// swap code shown:
		if game23SliderChoice == .game2, let appearance2 = pendingAppearanceGame2 {
			ME2CodeField.text = appearance2.format()
			ME2CodeLabel.text = ME2CodeField.text
		} else if let appearance3 = pendingAppearanceGame3 {
			ME2CodeField.text = appearance3.format()
			ME2CodeLabel.text = ME2CodeField.text
		}
	}

	func sliderChanged(attribute: Shepard.Appearance.AttributeType, value: Int) {
		currentGame1Attributes[attribute] = value
	}

	func save() {
        guard shepard != nil else { return }
		startSpinner(inView: view)
		if currentGame == .game1 {
			var newAppearance = Shepard.Appearance("", fromGame: .game1, withGender: currentGender)
			for (attribute, value) in currentGame1Attributes {
				newAppearance.contents[attribute] = value > 0 ? value : 1
			}
			_ = shepard?.changed(appearance: newAppearance)
		} else if let appearanceCode = ME2CodeField.text {
			let newAppearance = Shepard.Appearance(
				appearanceCode,
				fromGame: game23SliderChoice,
				withGender: currentGender
			)
            _ = shepard?.changed(appearance: newAppearance)
		}
		stopSpinner(inView: view)
	}

	/// Opens the camera and OCR-scans for a valid appearance code.
	func openScanCode() {
		// the other buttons provide feedback, so do that here too
		UIView.animate(withDuration: 0.3, animations: { [weak self] in
			self?.scanCodeButton?.backgroundColor = .white
			self?.scanCodeButton?.alpha = 0.5
		}) { [weak self] _ in
			self?.scanCodeButton?.backgroundColor = .clear
			self?.scanCodeButton?.alpha = 1.0
		}
		// modal segue to camera scanner
		parent?.performSegue(withIdentifier: "Show ShepardFlow.AppearanceScanCode", sender: scanCodeButton)
	}

	// UITaxtFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder() // close keyboard
		return false
	}

	// MARK: Setup Page Elements

	func setup() {

		fetchData()

		if !didSetup { // first time
			// Game 2/3 selected:
			currentGame = shepard?.gameVersion
			ME23GameSegment.selectedSegmentIndex = currentGame == .game3 ? 1 : 0 // game 2 is default
			// Game 1 Sliders:
			var appearance1 = shepard?.appearance // value type == copy
			appearance1?.convert(toGame: .game1)
			pendingAppearanceGame1 = appearance1
			currentGame1Attributes = pendingAppearanceGame1?.contents ?? [:]
			// Game 2/3 Codes:
			var appearance2 = shepard?.appearance // value type == copy
			appearance2?.convert(toGame: .game2)
			pendingAppearanceGame2 = appearance2
			var appearance3 = shepard?.appearance // value type == copy
			appearance3?.convert(toGame: .game3)
			pendingAppearanceGame3 = appearance3
			ME2CodeField.text = currentGame == .game2
				? pendingAppearanceGame2?.format()
				: pendingAppearanceGame3?.format()
		}

		ME2AlertLabel.text = nil
		ME2NoticeLabel.text = nil
		if let initError = pendingAppearanceGame1?.initError {
			ME2AlertLabel.text = initError
		} else if pendingAppearanceGame1?.alerts.isEmpty == false {
			ME2AlertLabel.text = convertAlert
		} else if pendingAppearanceGame1?.notices.isEmpty == false {
			ME2NoticeLabel.text = convertNotice
		}

		ME2AlertLabel.isHidden = true
		ME2NoticeLabel.isHidden = true
		ME2CodeField.delegate = self

		ME2CodeChanged(ME2CodeField)

		didSetup = true
		view.layoutIfNeeded()
	}

	func fetchData() {
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		shepard = App.current.game?.shepard
	}

	func fetchDummyData() {
		shepard = Shepard.getDummy()
	}

	func sizeAttributesTableView(relayout: Bool = false) {
		guard !UIWindow.isInterfaceBuilder else { return }
		let attributesTableViewHeight = round(attributesTableView.contentSize.height)
		attributesTableViewHeightConstraint?.constant = attributesTableViewHeight
		if oldAttributesTableViewHeight != attributesTableViewHeight {
//			print("laying out \(oldAttributesTableViewHeight) " +
//				"\(attributesTableViewHeight) \(attributesTableView.frame)")
			oldAttributesTableViewHeight = attributesTableViewHeight
//            if relayout && attributesTableViewHeight != attributesTableView.bounds.height {
//				view.setNeedsLayout()
//            }
			view.layoutIfNeeded()
//			print("final frame \(attributesTableView.frame)")
		} else {
//			print("not laying out \(oldAttributesTableViewHeight) " +
//				"\(attributesTableViewHeight) \(attributesTableView.frame)")
		}
	}
}

// MARK: Protocol - UITableViewDelegate
extension ShepardAppearanceController {

	func getSortedGroups(_ gender: Shepard.Gender) -> [Shepard.Appearance.GroupType] {
		return Shepard.Appearance.sortedAttributeGroups.filter {
			Shepard.Appearance.attributeGroups[gender]?[$0] != nil
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		sortedGroups = getSortedGroups(currentGender)
		return sortedGroups.count
	}

	func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		let group = Shepard.Appearance.sortedAttributeGroups[section]
		return Shepard.Appearance.attributeGroups[currentGender]?[group]?.count ?? 0
	}

	func tableView(
		_ tableView: UITableView,
		viewForHeaderInSection section: Int
	) -> UIView? {
		let group = Shepard.Appearance.sortedAttributeGroups[section]
		return ShepardAppearanceHeadingNib.loadNib(title: group.title)
	}

	func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(
				withIdentifier: "Appearance Slider"
			) as? ShepardAppearanceSliderCell {
			setupSliderCell(cell, indexPath: indexPath)
			return cell
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 88
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 35
	}

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
        attributesTableView?.rowHeight = UITableView.automaticDimension
        attributesTableView?.estimatedRowHeight = 88
		attributesTableView?.register(
			UINib(nibName: "ShepardAppearanceSliderCell", bundle: bundle),
			forCellReuseIdentifier: "Appearance Slider"
		)
	}

	func setupSliderCell(_ cell: ShepardAppearanceSliderCell, indexPath: IndexPath) {
		let group = Shepard.Appearance.sortedAttributeGroups[(indexPath as NSIndexPath).section]
		guard let attribute = Shepard.Appearance
				.attributeGroups[currentGender]?[group]?[(indexPath as NSIndexPath).row]
		else {
			return
		}
		cell.define(
			attributeType: attribute,
			value: pendingAppearanceGame1?.contents[attribute],
			maxValue: Shepard.Appearance.slidersMax[currentGender]?[attribute]?[.game1],
			title: attribute.title,
			notice: pendingAppearanceGame1?.notices[attribute]?.stringValue
				?? Shepard.Appearance.defaultNotices[attribute]?.stringValue,
			error: pendingAppearanceGame1?.alerts[attribute]?.stringValue,
			onChange: sliderChanged
		)
	}

	// MARK: Protocol - UIGestureRecognizerDelegate
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		// (swipe back interferes... badly... with sliders)
		return false
	}

	func reloadDataOnChange(_ x: Bool = false) {
		DispatchQueue.main.async {
			self.setup()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadDataOnChange)
	}
}

extension ShepardAppearanceController: Spinnerable {}
