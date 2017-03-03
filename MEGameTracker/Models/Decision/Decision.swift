//
//  Decision.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct Decision {
// MARK: Constants

// MARK: Properties
    public var generalData: DataDecision

    public fileprivate(set) var id: String
    
    /// (GameModifying, GameRowStorable Protocol) 
    /// This value's game identifier.
    public var gameSequenceUuid: String?
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
    public var pendingCloudChanges: SerializableData?
    /// (CloudDataStorable Protocol)  
    /// A copy of the last cloud kit record.
    public var lastRecordData: Data?
    
    public fileprivate(set) var isSelected = false
    
// MARK: Computed Properties

    public var gameVersion: GameVersion { return generalData.gameVersion }
    public var name: String { return generalData.name }
    public var description: String? { return generalData.description }
    public var loveInterestId: String? { return generalData.loveInterestId }
    public var sortIndex: Int { return generalData.sortIndex }
    public var blocksDecisionIds: [String] { return generalData.blocksDecisionIds }
    
    public var isAvailable: Bool {
        if generalData.dependsOnDecisions.isEmpty {
            return true
        }
        var isAvailable = true
        for set in generalData.dependsOnDecisions {
            if let decision = Decision.get(id: set.id) , decision.isSelected != set.value {
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
        gameSequenceUuid: String? = App.current.game?.uuid,
        generalData: DataDecision,
        data: SerializableData? = nil
    ) {
        self.id = id
        self.generalData = generalData
        self.gameSequenceUuid = gameSequenceUuid
        if let data = data {
            setData(data)
        }
    }
    
    func unsetBlockedDecisionIds(with manager: SimpleSerializedCoreDataManageable? = nil) {
        let manager = manager ?? defaultManager
        guard isSelected else { return }
        for decisionId in blocksDecisionIds {
            if var decision = Decision.get(id: decisionId, with: manager) , decision.isSelected {
                decision.isSelected = false
                _ = decision.saveAnyChanges(with: manager)
            }
        }
    }
    
}

// MARK: Data Change Actions
extension Decision {
    
    /// Applies a set of changes to this object
    public mutating func change(data: SerializableData) {
        if let isSelected = data["isSelected"]?.bool {
            change(isSelected: isSelected)
        }
    }

    public mutating func change(
        isSelected: Bool,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) {
        guard isSelected != self.isSelected else { return }
        self.isSelected = isSelected
        markChanged()
        notifySaveToCloud(fields: ["isSelected": isSelected])
        if isSave {
            _ = saveAnyChanges()
        }
        if isCascadeChanges != .none  && !GamesDataBackup.current.isSyncing {
            if self.loveInterestId != nil {
                cascadeChangeLoveInterest(isSave: isSave, isNotify: isNotify)
            }
            if isSelected {
                for decisionId in blocksDecisionIds {
                    // new thread?
                    var decision = Decision.get(id: decisionId)
                    decision?.change(isSelected: false, isSave: true)
                }
            }
        }
        if isNotify {
            Decision.onChange.fire((id: id, object: self))
        }
    }
    
    fileprivate func cascadeChangeLoveInterest(
        isSave: Bool = true,
        isNotify: Bool = true
    ) {
        // mark the correlating love interest decision for later tracking
        guard let loveInterestId = self.loveInterestId,
            var shepard = App.current.game?.getShepardFromVersion(gameVersion) ?? App.current.game?.shepard
        else {
            return
        }
        if isSelected && shepard.loveInterestId != loveInterestId {
            shepard.change(loveInterestId: loveInterestId, isSave: isSave, isNotify: isNotify, isCascadeChanges: .none)
        } else if !isSelected && shepard.loveInterestId == loveInterestId {
            shepard.change(loveInterestId: nil, isSave: isSave, isNotify: isNotify, isCascadeChanges: .none)
        }
    }
    
}


// MARK: Dummy data for Interface Builder
extension Decision {
    public static func getDummy(json: String? = nil) -> Decision? {
        let json = json ?? "{\"id\":\"1.1\",\"gameVersion\":\"1\",\"name\":\"Helped Jenna in Chora's Den\",\"description\":\"If you help Jenna in Citadel: Rita's Sister, she can save Conrad Verner's life in Game 3.\"}"
        if var baseDecision = DataDecision(serializedString: json) {
            baseDecision.isDummyData = true
            let decision = Decision(id: "1", generalData: baseDecision)
            return decision
        }
        return nil
    }
}

// MARK: SerializedDataStorable
extension Decision: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        // from db:
        list["id"] = id
        list["isSelected"] = isSelected
        list = serializeDateModifiableData(list: list)
        list = serializeGameModifyingData(list: list)
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Decision: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let dataDecision = DataDecision.get(id: id),
              let gameSequenceUuid = data["gameSequenceUuid"]?.string
        else {
            return nil
        }
        
        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataDecision, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        id = data["id"]?.string ?? id
        if generalData.id != id {
            generalData = DataDecision.get(id: id) ?? generalData
        }
        
        unserializeDateModifiableData(data: data)
        unserializeGameModifyingData(data: data)
        unserializeLocalCloudData(data: data)
        
        isSelected = data["isSelected"]?.bool ?? isSelected
    }
    
}

// MARK: DateModifiable
extension Decision: DateModifiable {}

// MARK: GameModifying
extension Decision: GameModifying {}

// MARK: Sorting
extension Decision {
    
    /// Sorts by availability, then by sortIndex, then by name
    static func sort(_ a: Decision, b: Decision) -> Bool {
        if a.gameVersion != b.gameVersion {
            return a.gameVersion.stringValue < b.gameVersion.stringValue
        } else if a.sortIndex != b.sortIndex {
            return a.sortIndex < b.sortIndex
        } else {
            return a.id < b.id
        }
    }
}

// MARK: Equatable
extension Decision: Equatable {}

public func ==(a: Decision, b: Decision) -> Bool { // not true equality, just same db row
    return a.id == b.id
}
