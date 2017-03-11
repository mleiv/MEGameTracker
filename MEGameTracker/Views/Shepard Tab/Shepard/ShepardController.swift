//
//  ShepardController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class ShepardController: UIViewController, Spinnerable, UINavigationControllerDelegate {

// MARK: Outlets 

	@IBOutlet weak var headerWrapper: UIView!
	@IBOutlet weak var headerLinks: UIStackView!

	@IBOutlet weak var nameField: UITextField!
		var testNameLabel = UILabel()
		var testNameWidth: CGFloat!
	@IBOutlet weak var surnameLabel: UILabel!
		var minSurnameWidth: CGFloat!
	@IBOutlet weak var genderSegment: UISegmentedControl!
	@IBOutlet weak var gameSegment: UISegmentedControl!

	@IBOutlet weak var photoImageView: UIImageView!

	// Appearanceable
	@IBOutlet weak var appearanceLinkView: ValueDataRow?
	lazy var appearanceType: AppearanceLinkType = {
		return AppearanceLinkType(controller: self, view: self.appearanceLinkView) { [weak self] sender in
			self?.openChangeableSegue("Appearance", sender: sender)
		}
	}()
	// Backstory
	@IBOutlet weak var shepardOriginRow: ValueAltDataRow?
	lazy var shepardOriginRowType: ShepardOriginRowType = {
		return ShepardOriginRowType(controller: self, view: self.shepardOriginRow) { [weak self] sender in
			self?.openChangeableSegue("Origin", sender: sender)
		}
	}()
	@IBOutlet weak var shepardReputationRow: ValueAltDataRow?
	lazy var shepardReputationRowType: ShepardReputationRowType = {
		return ShepardReputationRowType(controller: self, view: self.shepardReputationRow) { [weak self] sender in
			self?.openChangeableSegue("Reputation", sender: sender)
		}
	}()
	@IBOutlet weak var shepardClassRow: ValueAltDataRow?
	lazy var shepardClassRowType: ShepardClassRowType = {
		return ShepardClassRowType(controller: self, view: self.shepardClassRow) { [weak self] sender in
			self?.openChangeableSegue("Class", sender: sender)
		}
	}()
	// DecisionsListLinkable
	@IBOutlet weak var decisionsListLinkView: ValueDataRow?
	lazy var decisionsListLinkType: DecisionsListLinkType = {
		return DecisionsListLinkType(controller: self, view: self.decisionsListLinkView) { [weak self] sender in
			self?.openChangeableSegue("Decisions", sender: sender)
		}
	}()
	// Love Interest
	@IBOutlet weak var shepardLoveInterestRow: ShepardLoveInterestRow?
	lazy var shepardLoveInterestRowType: ShepardLoveInterestRowType = {
		return ShepardLoveInterestRowType(controller: self, view: self.shepardLoveInterestRow) { [weak self] sender in
			self?.openChangeableSegue("Love Interest", sender: sender)
		}
	}()
	// Notesable
	@IBOutlet weak var notesView: NotesView?
	public var notes: [Note] = []
	// RelatedLinksable
	@IBOutlet public weak var relatedLinksView: RelatedLinksView?
	public var relatedLinks: [String] = []
	// Slider Rows
	@IBOutlet weak var levelRow: SliderRow?
	@IBOutlet weak var paragonRow: SliderRow?
	@IBOutlet weak var renegadeRow: SliderRow?
	// VoiceActorLinkable
	@IBOutlet public weak var voiceActorLinkView: VoiceActorLinkView?

	@IBAction func startChangingName(_ sender: AnyObject) { prepNameChange() }
	@IBAction func nameChanged(_ sender: UITextField) { sizeName() }
	@IBAction func doneChangingName(_ sender: AnyObject) {
		processChangedName()
		_ = sender.resignFirstResponder()
	}
	@IBAction func genderChanged(_ sender: AnyObject) {
		changeGender(index: genderSegment.selectedSegmentIndex)
	}
	@IBAction func gameChanged(_ sender: AnyObject) {
		changeGame(index: gameSegment.selectedSegmentIndex)
	}
	@IBAction func changePhoto(_ sender: UIButton) { pickPhoto(sender) }

// MARK: Variables

	public var shepard: Shepard?
	public var originHint: String? { return shepard?.fullName }

	// VoiceActorLinkable
	public var voiceActorName: String?

	lazy var imagePicker: UIImagePickerController = {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		return imagePicker
	}()

// MARK: Initializers

	override public func viewDidLoad() {
		super.viewDidLoad()
		if !UIWindow.isInterfaceBuilder && App.isInitializing {
			App.onDidInitialize.subscribe(on: self) { [weak self] in
				DispatchQueue.main.async { [weak self] in
					self?.setup()
					self?.view.layoutIfNeeded()
				}
			}
		} else {
			setup()
		}
		startListeners()
	}

	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

// MARK: Setup

	func setup() {
		startSpinner(inView: view)
		defer { stopSpinner(inView: view) }

		fetchData()

		genderSegment.selectedSegmentIndex = shepard?.gender == .male ? 0 : 1

		gameSegment.selectedSegmentIndex = shepard?.gameVersion.index ?? 0

		nameField.text = shepard?.name.stringValue

		surnameLabel.text = Shepard.DefaultSurname

		guard !UIWindow.isInterfaceBuilder else { return }

		setupPhotoValue()

		setupAppearanceLink()

		setupBackstory()

		setupDecisionsListLink()

		setupLevel()

		setupLoveInterest()

		setupNotes()

		setupParagon()

		setupRelatedLinks()

		setupRenegade()

		setupVoiceActor()
	}

	func fetchData() {
		guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
		shepard = App.current.game?.shepard
	}

	func fetchDummyData() {
		shepard = Shepard.getDummy()
	}

	func reloadDataOnChange() {
		guard !UIWindow.isInterfaceBuilder && !App.isInitializing else { return }
		DispatchQueue.main.async {
			self.setup()
		}
	}

// MARK: Actions

	/// Some difficulty changing sizes led to this :/
	func prepNameChange() {
		testNameLabel.text = nameField.text
		testNameLabel.font = nameField.font
		testNameLabel.sizeToFit()
		testNameWidth = testNameLabel.bounds.width
		testNameLabel.text = " \(Shepard.DefaultSurname)"
		testNameLabel.sizeToFit()
		minSurnameWidth = testNameLabel.bounds.width
	}

	func sizeName() {
		testNameLabel.text = nameField.text
		testNameLabel.sizeToFit()
		if let lastWidth = testNameWidth {
			let widthChange = min(surnameLabel.frame.size.width - minSurnameWidth, testNameLabel.bounds.width - lastWidth)
			nameField.frame.size.width += widthChange
			surnameLabel.frame.origin.x += widthChange
			surnameLabel.frame.size.width -= widthChange
		}
		testNameWidth = testNameLabel.bounds.width
	}

	func processChangedName() {
		startSpinner(inView: view)
		if nameField.text == nil || nameField.text!.isEmpty {
			nameField.text = shepard?.name.stringValue
			sizeName()
		} else {
			shepard?.change(name: nameField.text)
		}
		_ = shepard?.saveAnyChanges()
		nameField.superview?.setNeedsLayout()
		nameField.superview?.layoutIfNeeded()
		stopSpinner(inView: view)
	}

	func changeGender(index: Int) {
		startSpinner(inView: view)
		shepard?.change(gender: index == 0 ? .male : .female)
		stopSpinner(inView: view)
	}

	func changeGame(index: Int) {
		startSpinner(inView: view)
		let newGame: GameVersion = {
			switch index {
			case 0: return .game1
			case 1: return .game2
			case 2: return .game3
			default: return .game1
			}
		}()
		App.current.changeGameVersion(newGame)
		// reload shepard:
		fetchData()
		stopSpinner(inView: view)
	}

// MARK: Segues

	func openChangeableSegue(_ sceneId: String, sender: AnyObject!) {
		DispatchQueue.main.async {
			self.startSpinner(inView: self.view)
		}
		DispatchQueue.global(qos: .background).async {
			if let parentController = self.parent as? MESplitViewController {
				let ferriedSegue: FerriedPrepareForSegueClosure = { _ in }
				DispatchQueue.main.async {
					parentController.performChangeableSegue("Show ShepardFlow.\(sceneId)", sender: sender, ferriedSegue: ferriedSegue)
					self.stopSpinner(inView: self.view)
				}
			}
			DispatchQueue.main.async {
				self.stopSpinner(inView: self.view)
			}
		}
	}

// MARK: Listeners

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		//listen for shepard changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadDataOnChange)
//		// listen for love interest decision changes
//		Decision.onChange.cancelSubscription(for: self)
//		_ = Decision.onChange.subscribe(on: self) { [weak self] changed in
//			if let object = changed.object, object.loveInterestId != nil {
//				DispatchQueue.main.async {
//					self?.setupLoveInterest()
//				}

//			}

//		}
	}

}

extension ShepardController: UIImagePickerControllerDelegate {

	func pickPhoto(_ sender: UIButton) {
		let imageController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)

		imageController.addAction(UIAlertAction(title: "Camera Roll", style: UIAlertActionStyle.default) { _ in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				self.imagePicker.sourceType = .photoLibrary
				self.imagePicker.allowsEditing = true
				self.present(self.imagePicker, animated: true, completion: nil)
			}
		})

		if UIImagePickerController.availableCaptureModes(for: .rear) != nil { // prevent simulator error
			imageController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { _ in
				if UIImagePickerController.isSourceTypeAvailable(.camera) {
					self.imagePicker.sourceType = .camera
					self.imagePicker.allowsEditing = true
					self.present(self.imagePicker, animated: true, completion: nil)
				}
			})
		}

		imageController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in })

		let iPadPopover = imageController.popoverPresentationController
		iPadPopover?.sourceRect = sender.frame
		iPadPopover?.sourceView = self.view

		present(imageController, animated: true, completion: nil)
	}

	public func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingImage image: UIImage,
		editingInfo: [String : AnyObject]?
	) {
		picker.dismiss(animated: true, completion: nil)
		if App.current.game?.shepard?.savePhoto(image: image) == true {
			setupPhotoValue()
		} else {
			let alert = UIAlertController(
				title: nil,
				message: "There was an error saving this image",
				preferredStyle: UIAlertControllerStyle.alert
			)
			alert.addAction(UIAlertAction(
				title: "Try Again",
				style: UIAlertActionStyle.default,
				handler: { _ in
					alert.dismiss(animated: true, completion: nil)
				}
			))
			present(alert, animated: true, completion: nil)
		}
	}

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

}

extension ShepardController { // Appearance

	func setupAppearanceLink() {
		appearanceType.setupView()
	}
}

extension ShepardController { // Backstory
	//public var shepard: Shepard? // already declared

	func setupBackstory() {
		shepardOriginRowType.setupView()
		shepardReputationRowType.setupView()
		shepardClassRowType.setupView()
	}
}

extension ShepardController: DecisionsListLinkable {

	func setupDecisionsListLink() {
		decisionsListLinkType.setupView()
	}
}

extension ShepardController { // Love Interest
	//public var shepard: Shepard? // already declared

	func setupLoveInterest() {
		shepardLoveInterestRowType.setupView()
	}
}

extension ShepardController {

	func setupPhotoValue() {
		Photo.addPhoto(from: shepard, toView: photoImageView, placeholder: UIImage.placeholder())
	}
}

extension ShepardController: Notesable {
	//public var notesView: NotesView? // already declared
	//public var originHint: String? // already declared
	//public var notes: [Note] // already declared

	func setupNotes() {
		shepard?.getNotes { [weak self] notes in
			DispatchQueue.main.async {
				self?.notes = notes
				self?.notesView?.controller = self
				self?.notesView?.setup()
			}
		}
	}

	public func getBlankNote() -> Note? {
		return shepard?.newNote()
	}

	public func didSaveNotes(_ notes: [Note]) {
		// nothing
	}
}

extension ShepardController: RelatedLinksable {
	//public var relatedLinks: [String] // already declared

	func setupRelatedLinks() {
		relatedLinks = ["https://masseffect.wikia.com/wiki/Commander_Shepard"]
		relatedLinksView?.controller = self
		relatedLinksView?.setup()
	}
}

extension ShepardController { // Slider Rows
	func setupLevel() {
		guard levelRow != nil else { return }
		levelRow?.initialize(
			value: shepard?.level ?? 1,
			minValue: 1,
			maxValue: shepard?.gameVersion.maxShepardLevel ?? 1,
			onChange: { [weak self] (value: Int) in
				guard value != self?.shepard?.level else { return }
				// some events depend on level
				let events = Event.getLevels(gameVersion: App.current.gameVersion)
				for (var event) in events {
					let level = Int(event.id.stringFrom(-2))
					if level <= value && !event.isTriggered {
						event.change(isTriggered: true, isSave: true)
					} else if level > value && event.isTriggered {
						event.change(isTriggered: false, isSave: true)
					}
				}
				self?.shepard?.change(level: value)
				_ = self?.shepard?.saveAnyChanges()
			}
		)
		levelRow?.setupView()
	}

	func setupParagon() {
		guard paragonRow != nil else { return }
		paragonRow?.initialize(
			value: shepard?.paragon ?? 0,
			minValue: 0,
			maxValue: 100,
			onChange: { [weak self] (value: Int) in
				guard value != self?.shepard?.paragon else { return }
				// some events depend on paragon
				let events = Event.getParagons(gameVersion: App.current.gameVersion)
				for (var event) in events {
					let eventValue = event.id.stringFrom(-2)
					let paragon = eventValue != "00" ? Int(eventValue) : 100
					if paragon <= value && !event.isTriggered {
						event.change(isTriggered: true, isSave: true)
					} else if paragon > value && event.isTriggered {
						event.change(isTriggered: false, isSave: true)
					}
				}
				self?.shepard?.change(paragon: value)
				_ = self?.shepard?.saveAnyChanges()
			}
		)
		paragonRow?.setupView()
	}

	func setupRenegade() {
		guard renegadeRow != nil else { return }
		renegadeRow?.initialize(
			value: shepard?.renegade ?? 0,
			minValue: 0,
			maxValue: 100,
			onChange: { [weak self] (value: Int) in
				guard value != self?.shepard?.renegade, let gameVersion = self?.shepard?.gameVersion else { return }
				// some events depend on renegade
				let events = Event.getRenegades(gameVersion: gameVersion)
				for (var event) in events {
					let eventValue = event.id.stringFrom(-2)
					let renegade = eventValue != "00" ? Int(eventValue) : 100
					if renegade <= value && !event.isTriggered {
						event.change(isTriggered: true, isSave: true)
					} else if renegade > value && event.isTriggered {
						event.change(isTriggered: false, isSave: true)
					}
				}
				self?.shepard?.change(renegade: value)
				_ = self?.shepard?.saveAnyChanges()
			}
		)
		renegadeRow?.setupView()
	}
}

extension ShepardController: VoiceActorLinkable {
	//public var voiceActorName: String // already declared

	func setupVoiceActor() {
		voiceActorName = shepard?.gender == .male ? "Mark Meer" : "Jennifer Hale"
		voiceActorLinkView?.controller = self
		voiceActorLinkView?.setup()
	}
}
