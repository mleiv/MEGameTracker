//
//  PersonController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit
import SafariServices

// swiftlint:disable file_length
// TODO: Refactor

final public class PersonController: UIViewController, Spinnerable, UINavigationControllerDelegate, UITextViewDelegate {

	var person: Person? {
		// TODO: fix this, bad didSet
		didSet {
			if oldValue != nil && oldValue != person {
				reloadDataOnChange()
			}
		}
	}

	public var originHint: String? { return "\(person?.personType.stringValue ?? ""): \(person?.name ?? "")" }

	@IBOutlet weak var headerWrapper: UIView!

	@IBOutlet weak var nameLabel: UILabel!

	@IBOutlet weak var heartButton: HeartButton!

	@IBOutlet weak var photoImageView: UIImageView!

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var organizationLabel: UILabel!

	@IBOutlet weak var gameSegments: GameSegments?

	lazy var imagePicker: UIImagePickerController = {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		return imagePicker
	}()

	// Decisionsable
	@IBOutlet public weak var decisionsView: DecisionsView?
	public var decisions: [Decision] = [] {
		didSet {
			person?.relatedDecisionIds = decisions.map { $0.id } // local changes only
		}
	}
	// Describable
	@IBOutlet public weak var descriptionView: TextDataRow?
	lazy var descriptionType: DescriptionType = {
		return DescriptionType(controller: self, view: self.descriptionView)
	}()
	// Notesable
	@IBOutlet weak var notesView: NotesView?
	public var notes: [Note] = []
	// OriginHintable
	@IBOutlet public weak var originHintView: TextDataRow?
	public var referringOriginHint: String?
	lazy var originHintType: OriginHintType = { return OriginHintType(controller: self, view: self.originHintView) }()
	// RelatedLinksable
	@IBOutlet public weak var relatedLinksView: RelatedLinksView?
	public var relatedLinks: [String] = []
	// RelatedMissionsable
	@IBOutlet public weak var relatedMissionsView: RelatedMissionsView?
	public var relatedMissions: [Mission] = []
	// SideEffectsable
	@IBOutlet weak var sideEffectsView: SideEffectsView?
	public var sideEffects: [String]? = []
	// VoiceActorLinkable
	@IBOutlet public weak var voiceActorLinkView: VoiceActorLinkView?
	public var voiceActorName: String?

	var isUpdating = false

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	deinit {
		removeListeners()
	}

	func dummyData() {
		// swiftlint:disable line_length
		person = Person.getDummy(json: "{\"id\": 2,\"name\": \"Liara T'soni\",\"description\": \"An archeologist specializing in the ancient prothean culture, Liara is the \\\"pureblood\\\" daughter of Matriarch Benezia, and doesn't know her father. At 106 - young for an asari - she has eschewed the typical frivolities of youth and instead pursued a life of scholarly solitude.\",\"personType\": \"Squad\",\"isMaleLoveInterest\": true,\"isFemaleLoveInterest\": true,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"photo\": \"Default Liara\",\"gameVersion\": true,\"relatedLinks\": \"[\\\"https://masseffect.wikia.com/wiki/Liara_T%27Soni\\\"]\",\"voiceActor\": \"Ali Hillis\"}")
		// swiftlint:enable line_length
	}

	func setup() {
		guard nameLabel != nil else { return } // make sure all outlets are connected

		// check if game version has changed, and change if it has (and person is available that game)
		let gameVersion = App.current.gameVersion
		let oldGameVersion = person?.gameVersion
		if gameVersion != oldGameVersion {
			_ = person?.changed(gameVersion: gameVersion) // isNotify: false
			return
		}

		setupValues()
	}

	func setupValues() {
		guard nameLabel != nil else { return }
		guard !UIWindow.isInterfaceBuilder else { return }
		guard !isUpdating else { return }

		isUpdating = true

//		if person?.isAvailable != true {
//			person?.changed(gameVersion: oldGameVersion)
//			return
//		}

		if UIWindow.isInterfaceBuilder {
			dummyData()
		}

		nameLabel.text = person?.name ?? ""

		parent?.navigationItem.title = person?.personType.stringValue ?? parent?.navigationItem.title

		if person?.isAvailableLoveInterest == true {
			heartButton.isParamour = person?.isParamour ?? true
			heartButton.toggle(isOn: person?.isLoveInterest ?? false)
			heartButton.onClick = changeLoveSetting
			heartButton.isHidden = false
		} else {
			heartButton.isHidden = true
		}

		titleLabel.text = person?.title ?? ""
		if person?.organization?.isEmpty == false {
			organizationLabel.text = person?.organization
			organizationLabel.isHidden = false
		} else {
			organizationLabel.isHidden = true
		}

		setupParsedText()

		setupPhotoValue()

		setupDecisions()

		setupDescription()

		setupGameSegments()

		setupNotes()

		setupOriginHint()

		setupRelatedLinks()

		setupRelatedMissions()

		setupSideEffects()

		setupVoiceActor()

		isUpdating = false
	}

	func reloadDataOnChange() {
		DispatchQueue.main.async {
			self.setupValues()
		}
	}

	func setupParsedText() {
//		if let markupTextView = descriptionTextView as? MarkupTextView {
//			markupTextView.markupText()
//			markupTextView.sizeToFit()
//		}
	}

	func setupPhotoValue() {
		Photo.addPhoto(from: person, toView: photoImageView, placeholder: UIImage.placeholder())
	}

	var shepardUuid = App.current.game?.shepard?.uuid
	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			person = person?.changed(gameVersion: App.current.gameVersion) //isNotify: false
			reloadDataOnChange()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		// listen for gameVersion changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
		// listen for decision changes
		Decision.onChange.cancelSubscription(for: self)
		_ = Decision.onChange.subscribe(on: self) { [weak self] changed in
			if self?.person?.loveInterestDecisionId == changed.id {
				self?.heartButton.toggle(isOn: self?.person?.isLoveInterest ?? false)
			}
		}
		// listen for changes to persons data
		Person.onChange.cancelSubscription(for: self)
		_ = Person.onChange.subscribe(on: self) { [weak self] changed in
			if self?.person?.id == changed.id, let newPerson = changed.object ?? Person.get(id: changed.id) {
				self?.person = newPerson
			}
		}
	}

	func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		App.onCurrentShepardChange.cancelSubscription(for: self)
		Decision.onChange.cancelSubscription(for: self)
		Person.onChange.cancelSubscription(for: self)
	}

	// MARK: Actions

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

	func changeLoveSetting(_ sender: AnyObject?) {
		let isOn = heartButton.isOn
		DispatchQueue.global(qos: .background).async {
			if let id = self.person?.loveInterestDecisionId {
				_ = Decision.get(id: id)?.changed(isSelected: isOn, isSave: true)
			}
		}
	}

	@IBAction func changePhoto(_ sender: UIButton) {
		pickPhoto(sender)
	}

	public func didSaveNotes(_ notes: [Note]) {
		// nothing
	}

}

extension PersonController: UIImagePickerControllerDelegate {

	func pickPhoto(_ sender: UIButton) {
		let imageController = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle:UIAlertController.Style.actionSheet
		)

		imageController.addAction(UIAlertAction(title: "Camera Roll", style: UIAlertAction.Style.default) { _ in
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				self.imagePicker.sourceType = .photoLibrary
				self.imagePicker.allowsEditing = true
				self.present(self.imagePicker, animated: true, completion: nil)
			}
		})

		if UIImagePickerController.availableCaptureModes(for: .rear) != nil { // prevent simulator error
			imageController.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { _ in
				if UIImagePickerController.isSourceTypeAvailable(.camera) {
					self.imagePicker.sourceType = .camera
					self.imagePicker.allowsEditing = true
					self.present(self.imagePicker, animated: true, completion: nil)
				}
			})
		}

		imageController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in })

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
		if let _ = person?.changed(image: image) {
			setupPhotoValue()
		} else {
			let alert = UIAlertController(
				title: nil,
				message: "There was an error saving this image",
				preferredStyle: UIAlertController.Style.alert
			)
			alert.addAction(UIAlertAction(
				title: "Try Again",
				style: UIAlertAction.Style.default,
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

extension PersonController: Decisionsable {
	//public var decisionsView: DecisionsView? // already declared
	//public var originHint: String? // already declared
	//public var decisions: [Decision] // already declared

	func setupDecisions() {
		if let decisionIds = person?.relatedDecisionIds {
			decisions = Decision.getAll(ids: decisionIds)
			decisions = decisions.sorted(by: Decision.sort)
		} else {
			decisions = []
		}
		decisionsView?.controller = self
		decisionsView?.setup()
	}
}

extension PersonController: Describable {
	public var descriptionMessage: String? {
		return person?.description
	}

	func setupDescription() {
		descriptionType.paddingSides = 0.0
		descriptionType.setupView()
	}
}

extension PersonController {
	func setupGameSegments() {
		var games: [GameVersion] = []
		for game in GameVersion.allCases {
			if person?.isAvailableInGame(game) == true {
				games.append(game)
			}
		}
		gameSegments?.games = games
	}
}

extension PersonController: Notesable {
	//public var notesView: NotesView? // already declared
	//public var originHint: String? // already declared
	//public var notes: [Note] // already declared

	func setupNotes() {
		person?.getNotes { [weak self] notes in
			DispatchQueue.main.async {
				self?.notes = notes
				self?.notesView?.controller = self
				self?.notesView?.setup()
			}
		}
	}

	public func getBlankNote() -> Note? {
		return person?.newNote()
	}
}

extension PersonController: OriginHintable {
	//public var originHint: String? // already declared

	func setupOriginHint() {
		if let referringOriginHint = self.referringOriginHint {
			originHintType.overrideOriginPrefix = "From"
			originHintType.overrideOriginHint = referringOriginHint
		} else {
			originHintType.overrideOriginHint = "" // block other origin hint
		}
		originHintType.setupView()
	}
}

extension PersonController: RelatedLinksable {
	//public var relatedLinks: [String] // already declared

	func setupRelatedLinks() {
		relatedLinks = person?.relatedLinks ?? []
		relatedLinksView?.controller = self
		relatedLinksView?.setup()
	}
}

extension PersonController: RelatedMissionsable {
	//public var relatedMissions: [Mission] // already declared

	func setupRelatedMissions() {
		person?.getRelatedMissions { [weak self] missions in
			DispatchQueue.main.async {
				self?.relatedMissions = missions
				self?.relatedMissionsView?.controller = self
				self?.relatedMissionsView?.setup()
			}
		}
	}
}

extension PersonController: SideEffectsable {
	//public var sideEffects: [String] // already declared

	func setupSideEffects() {
		sideEffects = person?.sideEffects ?? []
		sideEffectsView?.controller = self
		sideEffectsView?.setup()
	}
}

extension PersonController: VoiceActorLinkable {
	//public var voiceActorName: String // already declared

	func setupVoiceActor() {
		voiceActorName = person?.voiceActor
		voiceActorLinkView?.controller = self
		voiceActorLinkView?.setup()
	}
}
// swiftlint:enable file_length
