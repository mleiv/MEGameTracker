//
//  MissionController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/6/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit
import SafariServices

final public class MissionController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

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
        static func list() -> [MissionPageComponent] {
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

    var shepardUuid: String?
    
    public var mission: Mission? {
        didSet {
            // TODO: fix this, bad didSet
            if oldValue != nil && oldValue != mission {
                reloadDataOnChange()
            }
        }
    }
    
    public var originHint: String? { return mission?.name }
    
    @IBOutlet weak var nameLabel: MarkupLabel?
    
    @IBOutlet weak var checkboxImageView: UIImageView?
    
    // Aliasable
    @IBOutlet weak var aliasesView: TextDataRow?
    lazy var aliasesType: AliasesType = { return AliasesType(controller: self, view: self.aliasesView) }()
    // Available
    @IBOutlet weak var availabilityView: TextDataRow?
    public var availabilityMessage: String?
    lazy var availabilityType: AvailabilityType = { return AvailabilityType(controller: self, view: self.availabilityView) }()
    // Unavailable
    @IBOutlet weak var unavailabilityView: TextDataRow?
    public var unavailabilityMessage: String?
    lazy var unavailabilityType: UnavailabilityType = { return UnavailabilityType(controller: self, view: self.unavailabilityView) }()
    // ConversationRewardsable
    @IBOutlet weak var conversationRewardsView: ConversationRewardsView?
    // Decisionsable
    @IBOutlet public weak var decisionsView: DecisionsView?
    public var decisions: [Decision] = [] {
        didSet {
            mission?.decisionIds = decisions.map { $0.id } // local changes only
        }
    }
    // Describable
    @IBOutlet public weak var descriptionView: TextDataRow?
    lazy var descriptionType: DescriptionType = { return DescriptionType(controller: self, view: self.descriptionView) }()
    // MapLinkable
    @IBOutlet public weak var mapLinkView: MapLinkView?
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
        DispatchQueue.main.async{
            self.setup()
        }
    }
    
    func reloadOnShepardChange() {
        if shepardUuid != App.current.game?.shepard?.uuid {
            shepardUuid = App.current.game?.shepard?.uuid
            reloadDataOnChange()
        }
    }
    
    func startListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
        App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
        // listen for changes to mission data
        Mission.onChange.cancelSubscription(for: self)
        _ = Mission.onChange.subscribe(on: self) { [weak self] changed in
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
            nameLabel.attributedText = Styles.applyStyle(nameLabel.identifier ?? "", toString: self.mission?.name ?? "").toggleStrikethrough(isCompleted)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
                self.mission?.change(isCompleted: isCompleted, isSave: true)
                spinnerController?.stopSpinner(inView: self.view)
            }
        }
    }
    
    func setCheckboxImage(isCompleted: Bool, isAvailable: Bool) {
        if !isAvailable {
            checkboxImageView?.image = isCompleted ? MissionCheckbox.disabledFilled.getImage() : MissionCheckbox.disabledEmpty.getImage()
        } else {
            checkboxImageView?.image = isCompleted ? MissionCheckbox.filled.getImage() : MissionCheckbox.empty.getImage()
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
        availabilityType.setupView()
        pageLoadStatus.markIsDone(.availability)
        conditionalSpinnerStop()
    }
}

extension MissionController: Unavailable {
    //public var unavailabilityMessage: String? // already declared
    
    func setupUnavailability() {
        unavailabilityMessage = mission?.isAvailable == true ? mission?.unavailabilityAfterMessages.joined(separator: ", ") : nil
        unavailabilityType.setupView()
        pageLoadStatus.markIsDone(.unavailability)
        conditionalSpinnerStop()
    }
}

extension MissionController: ConversationRewardsable {
    //public var originHint: String? // already declared
    //public var mission: Mission? // already declared
    
    func setupConversationRewards() {
        conversationRewardsView?.controller = self
        pageLoadStatus.markIsDone(.conversationRewards)
        conditionalSpinnerStop()
    }
}

extension MissionController: Decisionsable {
    //public var originHint: String? // already declared
    //public var decisions: [Decision] // already declared
    
    func setupDecisions() {
        DispatchQueue.main.async { [weak self] in
            if let decisionIds = self?.mission?.decisionIds {
                self?.decisions = Decision.getAll(ids: decisionIds)
                self?.decisions = self?.decisions.sorted(by: Decision.sort) ?? []
            } else {
                self?.decisions = []
            }
            self?.decisionsView?.controller = self
            self?.pageLoadStatus.markIsDone(.decisions)
            self?.conditionalSpinnerStop()
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
            self?.mapLinkView?.controller = self
            self?.pageLoadStatus.markIsDone(.mapLink)
            self?.conditionalSpinnerStop()
        }
    }
}

extension MissionController: Notesable {
    //public var originHint: String? // already declared
    //public var notes: [Note] // already declared
    
    func setupNotes() {
        mission?.getNotes() { [weak self] notes in
            DispatchQueue.main.async{
                self?.notes = notes
                self?.notesView?.controller = self
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
        DispatchQueue.main.async { [weak self] in
            self?.objectives = self?.mission?.getObjectives() ?? []
            self?.objectivesView?.controller = self
            self?.pageLoadStatus.markIsDone(.objectives)
            self?.conditionalSpinnerStop()
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
        DispatchQueue.main.async { [weak self] in
            self?.relatedLinks = self?.mission?.relatedLinks ?? []
            self?.relatedLinksView?.controller = self
            self?.pageLoadStatus.markIsDone(.relatedLinks)
            self?.conditionalSpinnerStop()
        }
    }
}

extension MissionController: RelatedMissionsable {
    //public var relatedMissions: [Mission] // already declared
    
    func setupRelatedMissions() {
        mission?.getRelatedMissions() { [weak self] (missions: [Mission]) in
            DispatchQueue.main.async{
                self?.relatedMissions = missions
                self?.relatedMissionsView?.controller = self
                self?.pageLoadStatus.markIsDone(.relatedMissions)
                self?.conditionalSpinnerStop()
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
            self?.pageLoadStatus.markIsDone(.sideEffects)
            self?.conditionalSpinnerStop()
        }
    }
}

extension MissionController: Spinnerable {}
