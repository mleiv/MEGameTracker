//
//  Decision.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct Decision: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameSequenceUuid
        case isSelected
        case selectedDate
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public var generalData: DataDecision

	public internal(set) var id: String

	/// (GameModifying, GameRowStorable Protocol) 
	/// This value's game identifier.
	public var gameSequenceUuid: UUID?
	/// (DateModifiable Protocol)  
	/// Date when value was created.
	public var createdDate = Date()
	/// (DateModifiable Protocol)  
	/// Date when value was last changed.
	public var modifiedDate = Date()
	/// (CloudDataStorable Protocol)  
	/// Flag for whether the local object has changes not saved to the cloud.
	public var isSavedToCloud = false
	/// (CloudDataStorable Protocol)  
	/// A set of any changes to the local object since the last cloud sync.
	public var pendingCloudChanges = CodableDictionary()
	/// (CloudDataStorable Protocol)  
	/// A copy of the last cloud kit record.
	public var lastRecordData: Data?

    // used only in CoreData queries
    public var selectedDate: Date?

	public private(set) var isSelected = false

// MARK: Computed Properties

	public var gameVersion: GameVersion { return generalData.gameVersion }
	public var name: String { return generalData.name }
	public var description: String? { return generalData.description }
	public var loveInterestId: String? { return generalData.loveInterestId }
	public var sortIndex: Int { return generalData.sortIndex }
	public var blocksDecisionIds: [String] { return generalData.blocksDecisionIds }
    public var linkedEventIds: [String] { return generalData.linkedEventIds }

	public var isAvailable: Bool {
		if generalData.dependsOnDecisions.isEmpty {
			return true
		}
		var isAvailable = true
		for set in generalData.dependsOnDecisions {
			if let decision = Decision.get(id: set.id), decision.isSelected != set.value {
				isAvailable = false
				break
			}
		}
		return isAvailable
	}

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Decision?)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: UUID? = App.current.game?.uuid,
		generalData: DataDecision
	) {
		self.id = id
		self.gameSequenceUuid = gameSequenceUuid
        self.generalData = generalData
        setGeneralData()
	}

    public mutating func setGeneralData() {
        // nothing for now
    }
    public mutating func setGeneralData(_ generalData: DataDecision) {
        self.generalData = generalData
        setGeneralData()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameSequenceUuid = try container.decode(UUID.self, forKey: .gameSequenceUuid)
        generalData = DataDecision(id: id) // faulted for now
        isSelected = try container.decodeIfPresent(Bool.self, forKey: .isSelected) ?? isSelected
        selectedDate = try container.decodeIfPresent(Date.self, forKey: .selectedDate)
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameSequenceUuid, forKey: .gameSequenceUuid)
        try container.encode(isSelected, forKey: .isSelected)
        try container.encode(selectedDate, forKey: .selectedDate)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }

//    func unsetBlockedDecisionIds(with manager: CodableCoreDataStorable? = nil) {
//        let manager = manager ?? defaultManager
//        guard isSelected else { return }
//        for decisionId in blocksDecisionIds {
//            if var decision = Decision.get(id: decisionId, with: manager), decision.isSelected {
//                decision.isSelected = false
//                _ = decision.saveAnyChanges(with: manager)
//            }
//        }
//    }

}

// MARK: Data Change Actions
extension Decision {

    /// Returns a copy of this Decision with a set of changes applies
	public func changed(fromActionData data: [String: Any?]) -> Decision {
        if let isSelected = data["isSelected"] as? Bool {
            return changed(isSelected: isSelected)
        }
        return self
	}

    /// Return a copy of this Decision with isSelected changed
	public func changed(
		isSelected: Bool,
		isSave: Bool = true,
		isNotify: Bool = true,
		isCascadeChanges: EventDirection = .all
	) -> Decision {
		guard isSelected != self.isSelected else { return self }
        var decision = self
		decision.isSelected = isSelected
        decision.selectedDate = isSelected ? Date() : nil
		decision.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["isSelected": isSelected, "selectedDate": selectedDate]
        )
        if isCascadeChanges != .none  && !GamesDataBackup.current.isSyncing {
            if decision.loveInterestId != nil {
                decision.cascadeChangeLoveInterest(isSave: isSave, isNotify: isNotify)
            }
            if isSelected {
                for decisionId in decision.blocksDecisionIds {
                    // new thread?
                    _ = Decision.get(id: decisionId)?
                        .changed(isSelected: false, isSave: true, isCascadeChanges: .none)
                }
            }
            for event in linkedEventIds.map({ Event.get(id: $0) }).filter({ $0 != nil }).map({ $0! }) {
                _ = event.changed(isTriggered: isSelected, isSave: isSave, isNotify: isNotify)
            }
        }
        return decision
	}

    /// Performs common behaviors after an object change
    private mutating func changeEffects(
        isSave: Bool = true,
        isNotify: Bool = true,
        cloudChanges: [String: Any?] = [:]
    ) {
        markChanged()
        notifySaveToCloud(fields: cloudChanges)
        if isSave {
            _ = saveAnyChanges()
        }
        if isNotify {
            Decision.onChange.fire((id: id, object: self))
        }
    }

	private func cascadeChangeLoveInterest(
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		// mark the correlating love interest decision for later tracking
		guard let loveInterestId = self.loveInterestId,
			let loveInterest = Person.get(id: loveInterestId, gameVersion: gameVersion),
			loveInterest.isParamour, // require exclusive love interest to change shepard
			let shepard = App.current.game?.getShepardFromVersion(gameVersion) ?? App.current.game?.shepard
		else {
			return
		}
		if isSelected && shepard.loveInterestId != loveInterestId {
			_ = shepard.changed(loveInterestId: loveInterestId, isSave: isSave, isNotify: isNotify, isCascadeChanges: .none)
		} else if !isSelected && shepard.loveInterestId == loveInterestId {
			_ = shepard.changed(loveInterestId: nil, isSave: isSave, isNotify: isNotify, isCascadeChanges: .none)
		}
	}

}

// MARK: Dummy data for Interface Builder
extension Decision {
	public static func getDummy(json: String? = nil) -> Decision? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\":\"1.1\",\"gameVersion\":\"1\",\"name\":\"Helped Jenna in Chora's Den\",\"description\":\"If you help Jenna in Citadel: Rita's Sister, she can save Conrad Verner's life in Game 3.\"}"
        if var baseDecision = try? defaultManager.decoder.decode(DataDecision.self, from: json.data(using: .utf8)!) {
            baseDecision.isDummyData = true
            let decision = Decision(id: "1", generalData: baseDecision)
            return decision
        }
		// swiftlint:enable line_length
		return nil
	}
}

// MARK: DateModifiable
extension Decision: DateModifiable {}

// MARK: GameModifying
extension Decision: GameModifying {}

// MARK: Sorting
extension Decision {

	/// Sorts by availability, then by sortIndex, then by name
	static func sort(_ first: Decision, _ second: Decision) -> Bool {
		if first.gameVersion != second.gameVersion {
			return first.gameVersion.stringValue < second.gameVersion.stringValue
		} else if first.sortIndex != second.sortIndex {
			return first.sortIndex < second.sortIndex
		} else {
			return first.id < second.id
		}
	}
}

// MARK: Equatable
extension Decision: Equatable {
	public static func == (_ lhs: Decision, _ rhs: Decision) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Decision: Hashable {
	public var hashValue: Int { return id.hashValue }
}
