//
//  MissionController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/6/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit
import SafariServices

// swiftlint:disable file_length
// TODO: Refactor

final public class MissionController: UIViewController,
	UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

	/// A list of all page components, later tracked by a LoadStatus struct.
	enum MissionPageComponent: LoadStatusComponent {
		case aliases
		case availability
		case unavailability
		case conversationRewards
		case decisions
		case description
		case mapLink
		case notes
		case objectives
		case originHint
		case relatedLinks
		case relatedMissions
		case sideEffects
		static func all() -> [MissionPageComponent] {
			return [
				.aliases,
				.availability,
				.unavailability,
				.conversationRewards,
				.decisions,
				.description,
				.mapLink,
				.notes,
				.objectives,
				.originHint,
				.relatedLinks,
				.relatedMissions,
				.sideEffects,
			]
		}
	}

	var shepardUuid: UUID?

	public var mission: Mission? {
		didSet {
			// TODO: fix this, I hate didSet
			if oldValue != nil && oldValue != mission {
				reloadDataOnChange()
			}
		}
	}

	public var originHint: String? { return mission?.name }

	@IBOutlet weak var nameLabel: UILabel?

	@IBOutlet weak var checkboxImageView: UIImageView?

	// Aliasable
	@IBOutlet weak var aliasesView: TextDataRow?
	lazy var aliasesType: AliasesType = {
        return AliasesType(controller: self, view: self.aliasesView)
    }()
	// Available
	@IBOutlet weak var availabilityView: TextDataRow?
	public var availabilityMessage: String?
	lazy var availabilityRowType: AvailabilityRowType = {
		return AvailabilityRowType(controller: self, view: self.availabilityView)
	}()
	// Unavailable
	@IBOutlet weak var unavailabilityView: TextDataRow?
	public var unavailabilityMessage: String?
	lazy var unavailabilityRowType: UnavailabilityRowType = {
		return UnavailabilityRowType(controller: self, view: self.unavailabilityView)
	}()
	// ConversationRewardsable
	@IBOutlet weak var conversationRewardsView: ValueDataRow?
	lazy var conversationRewardsType: ConversationRewardsRowType = {
		return ConversationRewardsRowType(controller: self, view: self.conversationRewardsView)
	}()
	// Decisionsable
	@IBOutlet public weak var decisionsView: DecisionsView?
	public var decisions: [Decision] = [] {
		didSet {
			mission?.relatedDecisionIds = decisions.map { $0.id } // local changes only
		}
	}
	// Describable
	@IBOutlet public weak var descriptionView: TextDataRow?
	lazy var descriptionType: DescriptionType = {
        return DescriptionType(controller: self, view: self.descriptionView)
    }()
	// MapLinkable
	@IBOutlet public weak var mapLinkView: ValueDataRow?
	lazy var mapLinkType: MapLinkType = {
		return MapLinkType(controller: self, view: self.mapLinkView)
	}()
	public var inMapId: String? {
		didSet {
			mission?.inMapId = inMapId // local changes only
		}
	}
	// Notesable
	@IBOutlet weak var notesView: NotesView?
	public var notes: [Note] = []
	// Objectivesable
	@IBOutlet public weak var objectivesView: ObjectivesView?
	public var objectives: [MapLocationable] = []
	// OriginHintable
	@IBOutlet public weak var originHintView: TextDataRow?
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

	@IBAction func onClickCheckbox(_ sender: UIButton) {
		toggleCheckbox()
	}

	var isUpdating = false
	var pageLoadStatus = LoadStatus<MissionPageComponent>()

	override public func viewDidLoad() {
		super.viewDidLoad()
		setup()
		startListeners()
	}

	deinit {
		removeListeners()
	}

	func setup() {
		guard nameLabel != nil else { return } // make sure all outlets are connected

		pageLoadStatus.reset()
		startSpinner(inView: view)
		isUpdating = true
		defer {
			isUpdating = false
		}

		if mission?.inMissionId == nil, let missionId = mission?.id, let gameVersion = mission?.gameVersion {
			App.current.addRecentlyViewedMission(missionId: missionId, gameVersion: gameVersion)
		}

		if UIWindow.isInterfaceBuilder { fetchDummyData() }

		nameLabel?.text = mission?.name ?? ""

		if let type = mission?.missionType {
			parent?.navigationItem.title = mission?.pageTitle ?? type.stringValue
		}

		guard !UIWindow.isInterfaceBuilder else { return }

		shepardUuid = App.current.game?.shepard?.uuid

		setupAliases()

		setupAvailability()
		setupUnavailability()

		setCheckboxImage(isCompleted: mission?.isCompleted ?? false, isAvailable: mission?.isAvailable ?? false)

		setupConversationRewards()

		setupDecisions()

		setupDescription()

		setupMapLink()

		setupNotes()

		setupObjectives()

		setupOriginHint()

		setupRelatedLinks()

		setupRelatedMissions()

		setupSideEffects()
	}

	func fetchDummyData() {
		mission = Mission.getDummy()
	}

	func conditionalSpinnerStop() {
		if pageLoadStatus.isComplete {
			stopSpinner(inView: view)
		}
	}

	func reloadDataOnChange() {
		DispatchQueue.main.async {
			self.setup()
		}
	}

	func reloadOnShepardChange(_ x: Bool = false) {
		if shepardUuid != App.current.game?.shepard?.uuid {
			shepardUuid = App.current.game?.shepard?.uuid
			reloadDataOnChange()
		}
	}

	func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		App.onCurrentShepardChange.cancelSubscription(for: self)
		_ = App.onCurrentShepardChange.subscribe(with: self, callback: reloadOnShepardChange)
		// listen for changes to mission data
		Mission.onChange.cancelSubscription(for: self)
		_ = Mission.onChange.subscribe(with: self) { [weak self] changed in
			if self?.mission?.id == changed.id, let newMission = changed.object ?? Mission.get(id: changed.id) {
				self?.mission = newMission
				self?.reloadDataOnChange() // the didSet check will view these missions as identical and not fire
			}
		}
	}
	func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		App.onCurrentShepardChange.cancelSubscription(for: self)
		Mission.onChange.cancelSubscription(for: self)
	}
}

extension MissionController {
	func toggleCheckbox() {
		guard let nameLabel = self.nameLabel else { return }
		let isCompleted = !(self.mission?.isCompleted ?? false)
		let spinnerController = self as Spinnerable?
		DispatchQueue.main.async {
			spinnerController?.startSpinner(inView: self.view)
			self.setCheckboxImage(isCompleted: isCompleted, isAvailable: self.mission?.isAvailable ?? false)
//			nameLabel.attributedText = Styles.current.applyStyle(nameLabel.identifier
//				?? "", toString: self.mission?.name ?? "").toggleStrikethrough(isCompleted)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
				_ = self.mission?.changed(isCompleted: isCompleted, isSave: true)
				spinnerController?.stopSpinner(inView: self.view)
			}
		}
	}

	func setCheckboxImage(isCompleted: Bool, isAvailable: Bool) {
		if !isAvailable {
			checkboxImageView?.image = isCompleted
				? MissionCheckbox.disabledFilled.getImage()
				: MissionCheckbox.disabledEmpty.getImage()
		} else {
			checkboxImageView?.image = isCompleted
				? MissionCheckbox.filled.getImage()
				: MissionCheckbox.empty.getImage()
		}
	}
}

extension MissionController: Aliasable {
	public var currentName: String? { return mission?.name }
	public var aliases: [String] { return mission?.aliases ?? [] }

	func setupAliases() {
		aliasesType.setupView()
		pageLoadStatus.markIsDone(.aliases)
		conditionalSpinnerStop()
	}
}

extension MissionController: Available {
	//public var availabilityMessage: String? // already declared

	func setupAvailability() {
		availabilityMessage = mission?.unavailabilityMessages.joined(separator: ", ")
		availabilityRowType.setupView()
		pageLoadStatus.markIsDone(.availability)
		conditionalSpinnerStop()
	}
}

extension MissionController: Unavailable {
	//public var unavailabilityMessage: String? // already declared

	func setupUnavailability() {
		unavailabilityMessage = mission?.isAvailable == true
			? mission?.unavailabilityAfterMessages.joined(separator: ", ")
			: nil
		unavailabilityRowType.setupView()
		pageLoadStatus.markIsDone(.unavailability)
		conditionalSpinnerStop()
	}
}

extension MissionController: ConversationRewardsable {
	//public var originHint: String? // already declared
	//public var mission: Mission? // already declared

	func setupConversationRewards() {
		conversationRewardsType.setupView()
		pageLoadStatus.markIsDone(.conversationRewards)
		conditionalSpinnerStop()
	}
}

extension MissionController: Decisionsable {
	//public var originHint: String? // already declared
	//public var decisions: [Decision] // already declared

	func setupDecisions() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			if let decisionIds = self?.mission?.relatedDecisionIds {
				self?.decisions = Decision.getAll(ids: decisionIds)
				self?.decisions = self?.decisions.sorted(by: Decision.sort) ?? []
			} else {
				self?.decisions = []
			}
			DispatchQueue.main.async {
				self?.decisionsView?.controller = self
				self?.decisionsView?.setup()
				self?.pageLoadStatus.markIsDone(.decisions)
				self?.conditionalSpinnerStop()
			}
		}
	}
}

extension MissionController: Describable {
	public var descriptionMessage: String? {
		return mission?.description
	}

	func setupDescription() {
		descriptionType.setupView()
		pageLoadStatus.markIsDone(.description)
		conditionalSpinnerStop()
	}
}

extension MissionController: MapLinkable {
	//public var originHint: String? // already declared
	//public var inMapId: String? // already declared
	public var mapLocation: MapLocationable? { return mission }
	public var isShowInParentMap: Bool { return mission?.isShowInParentMap ?? false }
	func setupMapLink() {
		DispatchQueue.main.async { [weak self] in
			self?.inMapId = self?.mission?.inMapId
			self?.mapLinkType.setupView()
			self?.pageLoadStatus.markIsDone(.mapLink)
			self?.conditionalSpinnerStop()
		}
	}
}

extension MissionController: Notesable {
	//public var originHint: String? // already declared
	//public var notes: [Note] // already declared

	func setupNotes() {
		mission?.getNotes { [weak self] notes in
			DispatchQueue.main.async {
				self?.notes = notes
				self?.notesView?.controller = self
				self?.notesView?.setup()
				self?.pageLoadStatus.markIsDone(.notes)
				self?.conditionalSpinnerStop()
			}
		}
	}

	public func getBlankNote() -> Note? {
		return mission?.newNote()
	}
}

extension MissionController: Objectivesable {
	//public var objectives: [MapLocationable] // already declared

	func setupObjectives() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			self?.objectives = self?.mission?.getObjectives() ?? []
			DispatchQueue.main.async {
				self?.objectivesView?.controller = self
				self?.objectivesView?.setup()
				self?.pageLoadStatus.markIsDone(.objectives)
				self?.conditionalSpinnerStop()
			}
		}
	}
}

extension MissionController: OriginHintable {
	//public var originHint: String? // already declared

	func setupOriginHint() {
		DispatchQueue.main.async { [weak self] in
			if let parentMission = self?.mission?.parentMission {
				self?.originHintType.overrideOriginPrefix = "Under"
				self?.originHintType.overrideOriginHint = parentMission.name
			} else {
				self?.originHintType.overrideOriginHint = "" // block other origin hint
			}
			self?.originHintType.setupView()
			self?.pageLoadStatus.markIsDone(.originHint)
			self?.conditionalSpinnerStop()
		}
	}
}

extension MissionController: RelatedLinksable {
	//public var relatedLinks: [String] // already declared

	func setupRelatedLinks() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			self?.relatedLinks = self?.mission?.relatedLinks ?? []
			DispatchQueue.main.async {
				self?.relatedLinksView?.controller = self
				self?.relatedLinksView?.setup()
				self?.pageLoadStatus.markIsDone(.relatedLinks)
				self?.conditionalSpinnerStop()
			}
		}
	}
}

extension MissionController: RelatedMissionsable {
	//public var relatedMissions: [Mission] // already declared

	func setupRelatedMissions() {
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			self?.mission?.getRelatedMissions { (missions: [Mission]) in
				DispatchQueue.main.async {
					self?.relatedMissions = missions
					self?.relatedMissionsView?.controller = self
					self?.relatedMissionsView?.setup()
					self?.pageLoadStatus.markIsDone(.relatedMissions)
					self?.conditionalSpinnerStop()
				}
			}
		}
	}
}

extension MissionController: SideEffectsable {
	//public var sideEffects: [String] // already declared

	func setupSideEffects() {
		DispatchQueue.main.async { [weak self] in
			self?.sideEffects = self?.mission?.sideEffects ?? []
			self?.sideEffectsView?.controller = self
			self?.sideEffectsView?.setup()
			self?.pageLoadStatus.markIsDone(.sideEffects)
			self?.conditionalSpinnerStop()
		}
	}
}

extension MissionController: Spinnerable {}

// swiftlint:enable file_length
