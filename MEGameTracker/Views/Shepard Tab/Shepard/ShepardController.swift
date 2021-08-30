//
//  ShepardController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
// TODO: Refactor

final public class ShepardController: UIViewController, Spinnerable, UINavigationControllerDelegate {

// MARK: Outlets 

	@IBOutlet weak var headerLinks: UIStackView!

	@IBOutlet weak var nameField: UITextField!
		var testNameLabel = UILabel()
		var testNameWidth: CGFloat!
	@IBOutlet weak var surnameLabel: UILabel!
		var minSurnameWidth: CGFloat!
	@IBOutlet weak var genderSegment: UISegmentedControl!
	@IBOutlet weak var gameSegment: UISegmentedControl!
    @IBOutlet weak var legendarySegment: UISegmentedControl!

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
    @IBAction func legendaryChanged(_ sender: AnyObject) {
        changeLegendary(index: legendarySegment.selectedSegmentIndex)
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
            App.onDidInitialize.cancelSubscription(for: self)
			App.onDidInitialize.subscribe(with: self) { [weak self] (_) -> Void in
                DispatchQueue.main.async { () -> Void in
                    self?.setup()
                    self?.view.layoutIfNeeded()
                }
			}
            setupLoadingScreen()
		} else {
			setup()
		}
		startListeners()
	}

	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

// MARK: Setup

    func setupLoadingScreen() {
        let loadingGender: Shepard.Gender = Bool.random() ? .male : .female
        genderSegment.selectedSegmentIndex = loadingGender == .male ? 0 : 1
        photoImageView.image = UIImage(named: loadingGender == .male ? "Default BroShep" : "Default FemShep")
    }

	func setup() {
		startSpinner(inView: view)
		defer { stopSpinner(inView: view) }

		fetchData()

        guard let shepard = shepard else { return }

		genderSegment.selectedSegmentIndex = shepard.gender == .male ? 0 : 1

		gameSegment.selectedSegmentIndex = shepard.gameVersion.index
        
        legendarySegment.selectedSegmentIndex = shepard.isLegendary == false ? 0 : 1

		nameField.text = shepard.name.stringValue

        surnameLabel.text = Shepard.DefaultSurname + (shepard.duplicationCount > 1 ? " \(shepard.duplicationCount)" : "")

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
        // cache default photos to prevent confusing delay in gender swap
        for filePath in Shepard.DefaultPhoto.filePaths.flatMap({ $0.1 }).map({ $0.1 }) {
            _ = Photo(filePath: filePath)
        }
	}

	func fetchDummyData() {
		shepard = Shepard.getDummy()
	}

	func reloadDataOnChange(_ x: Bool = false) {
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
            // discard, wait for listener
            _ = shepard?.changed(name: nameField.text)
		}
		nameField.superview?.setNeedsLayout()
		nameField.superview?.layoutIfNeeded()
		stopSpinner(inView: view)
	}

	func changeGender(index: Int) {
		startSpinner(inView: view)
        // discard, wait for listener
        _ = shepard?.changed(gender: index == 0 ? .male : .female)
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
        App.current.changeGame { game in
            var game = game
            game?.change(gameVersion: newGame)
            return game
        }
		// reload shepard:
		fetchData()
		stopSpinner(inView: view)
	}
    
    func changeLegendary(index: Int) {
        startSpinner(inView: view)
        // discard, wait for listener
        _ = shepard?.changed(isLegendary: index == 0 ? false : true)
        // reload shepard:
        fetchData()
        stopSpinner(inView: view)
    }

// MARK: Segues

	func openChangeableSegue(_ sceneId: String, sender: AnyObject!) {
        startSpinner(inView: view)
        if let parentController = parent as? MESplitViewController {
            let ferriedSegue: FerriedPrepareForSegueClosure = { _ in }
            parentController.performChangeableSegue("Show ShepardFlow.\(sceneId)", sender: sender, ferriedSegue: ferriedSegue)
        }
        stopSpinner(inView: self.view)
	}

// MARK: Listeners

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		//listen for shepard changes
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(with: self) { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadDataOnChange()
            }
        }
//		// listen for love interest decision changes
//		Decision.onChange.cancelSubscription(for: self)
//		_ = Decision.onChange.subscribe(with: self) { [weak self] changed in
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
		let imageController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

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
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		picker.dismiss(animated: true, completion: nil)
        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage,
            var game = App.current.game,
            game.shepard?.savePhoto(image: image) == true {
            setupPhotoValue()
            App.current.changeGame(isSave: false, isNotify: false) { _ in game }
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
            self?.notes = notes
			DispatchQueue.main.async {
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
			onChange: { [weak self] value in
				Event.triggerLevelChange(value, for: self?.shepard)
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
			onChange: { [weak self] value in
				Event.triggerParagonChange(value, for: self?.shepard)
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
			onChange: { [weak self] value in
				Event.triggerRenegadeChange(value, for: self?.shepard)
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
// swiftlint:enable file_length

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
