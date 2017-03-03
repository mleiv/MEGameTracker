//
//  DataItem.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataItem: MapLocationable {
// MARK: Constants

// MARK: Properties

    internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

    public fileprivate(set) var id: String
    public fileprivate(set) var gameVersion: GameVersion
    fileprivate var _name: String = "Unknown"
    public var itemType: ItemType = .loot
    public var itemDisplayType: ItemDisplayType?
    public var description: String?
    public var price: String?
    
    public fileprivate(set) var relatedLinks: [String] = []
    public internal(set) var decisionIds: [String] = [] // transient changes in Mission
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
        return "\(itemType.titlePrefix)\(_name)"
    }
    
    public var rawEventData: SerializableData? {
        get{ return rawGeneralData["events"] }
        set{ rawGeneralData["events"] = newValue }
    }
    
    public var hasNoAdditionalData: Bool {
        if relatedLinks.count > 0 {
            return false
        }
        if description != nil {
            return false
        }
        return true
    }
    
    
// MARK: MapLocationable

    public var annotationNote: String?
    
    public var mapLocationType = MapLocationType.item
    public var mapLocationPoint: MapLocationPoint?
    public var inMapId: String?
    public var inMissionId: String?
    public var sortIndex = 0
    
    public var isHidden = false
    public var isAvailable: Bool = true
    public var unavailabilityMessages: [String] = []

//    public var searchableName: String // optional
//    public var linkToMapId: String? // optional
//    public var shownInMapId: String? // optional
    public var isShowInParentMap = true
//    public var isShowInList: Bool // optional
    public var isShowPin: Bool = true
    public var isOpensDetail = false
    
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
extension DataItem {
    
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
extension DataItem: SerializedDataStorable {

    public func getData() -> SerializableData {
        return rawGeneralData
    }
    
}

// MARK: SerializedDataRetrievable
extension DataItem: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
        else { return nil }
        
        self.init(id: id, gameVersion: gameVersion, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
        _name = data["name"]?.string ?? _name
        itemType = ItemType(stringValue: data["itemType"]?.string) ?? itemType
        itemDisplayType = ItemDisplayType(stringValue: data["itemDisplayType"]?.string)
        
        //optional values
        description = data["description"]?.string
        
        inMapId = data["inMapId"]?.string
        inMissionId = data["inMissionId"]?.string
        if let pointData = data["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
            mapLocationPoint = point
            isShowInParentMap = data["isShowInParentMap"]?.bool ?? false // don't deep link if we have map location
        } else {
            isShowInParentMap = data["isShowInParentMap"]?.bool ?? true // deep link by default
        }
        isShowPin = data["isShowPin"]?.bool ?? isShowPin
        annotationNote = data["annotationNote"]?.string
        sortIndex = data["sortIndex"]?.int ?? 0
        
        price = data["price"]?.string
        
        relatedLinks = (data["relatedLinks"]?.array ?? []).flatMap({ $0.string })
        decisionIds = (data["decisionIds"]?.array ?? []).flatMap({ $0.string })
        sideEffects = (data["sideEffects"]?.array ?? []).flatMap({ $0.string })
        relatedMissionIds = (data["relatedMissionIds"]?.array ?? []).flatMap({ $0.string })
        
        rawEventData = data["events"]
    }
    
}

//MARK: Equatable
extension DataItem: Equatable {}

public func ==(a: DataItem, b: DataItem) -> Bool { // not true equality, just same db row
    return a.id == b.id
}
