//
//  DataMission.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataMission: MapLocationable {
// MARK: Constants

// MARK: Properties

    internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

    public fileprivate(set) var id: String
    public fileprivate(set) var gameVersion: GameVersion
    fileprivate var _name: String = "Unknown"
    public var pageTitle: String?
    public var aliases: [String] = []
    public var missionType: MissionType = .mission
    public var description: String?
    
    public fileprivate(set) var relatedLinks: [String] = []
    public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Mission
    public fileprivate(set) var sideEffects: [String] = []
    public fileprivate(set) var relatedMissionIds: [String] = []
    public fileprivate(set) var photo: Photo?
    
    public var objectivesCountToCompletion: Int?
    public var conversationRewards = ConversationRewards()
    public var identicalMissionId: String?
    
    // Interface Builder
    public var isDummyData = false
    
// MARK: Computed Properties
    
    public var name: String {
        if missionType == .mission || missionType == .assignment {
            return _name
        } else {
            return "\(missionType.titlePrefix)\(_name)"
        }
    }
    
    public var rawEventData: SerializableData? {
        get{ return rawGeneralData["events"] }
        set{ rawGeneralData["events"] = newValue }
    }
    
// MARK: MapLocationable

    public var annotationNote: String?
    
    public var mapLocationType = MapLocationType.mission
    public var mapLocationPoint: MapLocationPoint?
    public var inMapId: String?
    public var inMissionId: String?
    public var sortIndex = 0
    
    public var isHidden = false
    public var isAvailable: Bool = true
    public var unavailabilityMessages: [String] = []
    
    public var searchableName: String {
        return aliases.isEmpty ? name : aliases.joined(separator: "|")
    }
//    public var linkToMapId: String?  // optional
    public var shownInMapId: String?
    public var isShowInParentMap = false
//    public var isShowInList: Bool // optional
    public var isShowPin: Bool = true
    public var isOpensDetail = true
    
    
// MARK: Initialization

    public init(id: String, gameVersion: GameVersion, data: SerializableData) {
        self.id = id
        self.gameVersion = gameVersion
        self.rawGeneralData = data
        
        rawEventData = data["events"]
        setData(data)
    }
}
    

// MARK: Retrieval Functions of Related Data
extension DataMission {
    
    public func getInheritableEvents() -> [SerializableData] {
        let inheritableEvents: [SerializableData] = (rawEventData?.array ?? []).map({
            if let eventType = EventType(stringValue: $0["type"]?.string) , eventType.isAppliesToChildren {
                return $0
            }
            return nil
        }).flatMap({ $0 })
        return inheritableEvents
    }
    
}

// MARK: SerializedDataStorable
extension DataMission: SerializedDataStorable {

    public func getData() -> SerializableData {
        return rawGeneralData
    }
    
}

// MARK: SerializedDataRetrievable
extension DataMission: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
        else { return nil }
        
        self.init(id: id, gameVersion: gameVersion, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        
        _name = data["name"]?.string ?? _name
        aliases = (data["aliases"]?.array ?? []).flatMap({ $0.string })
        description = data["description"]?.string
        
        missionType = MissionType(stringValue: data["missionType"]?.string) ?? missionType
        pageTitle = data["pageTitle"]?.string
        inMissionId = data["inMissionId"]?.string
        identicalMissionId = data["identicalMissionId"]?.string
        isOpensDetail = data["isOpensDetail"]?.bool ?? isOpensDetail
        
        conversationRewards = ConversationRewards(data: data["conversationRewards"]) ?? conversationRewards
        
        inMapId = data["inMapId"]?.string
        isShowInParentMap = data["isShowInParentMap"]?.bool ?? isShowInParentMap
        if let pointData = data["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
            mapLocationPoint = point
        }
        isShowPin = data["isShowPin"]?.bool ?? isShowPin
        annotationNote = data["annotationNote"]?.string
        sortIndex = data["sortIndex"]?.int ?? 0
        
        relatedLinks = (data["relatedLinks"]?.array ?? []).flatMap({ $0.string })
        relatedDecisionIds = (data["relatedDecisionIds"]?.array ?? []).flatMap({ $0.string })
        sideEffects = (data["sideEffects"]?.array ?? []).flatMap({ $0.string })
        relatedMissionIds = (data["relatedMissionIds"]?.array ?? []).flatMap({ $0.string })
        
        objectivesCountToCompletion = data["objectivesCountToCompletion"]?.int
        
        rawEventData = data["events"]
    }
    
}

//MARK: Equatable
extension DataMission: Equatable {
    public static func ==(a: DataMission, b: DataMission) -> Bool { // not true equality, just same db row
        return a.id == b.id
    }
}

// MARK: Hashable
extension DataMission: Hashable {
    public var hashValue: Int { return id.hashValue }
}

