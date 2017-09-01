//
//  DataMapLocationable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Defines common characterstics to all objects available for display on a map.
public protocol DataMapLocationable {
// MARK: Required
    var id: String { get }
    var name: String { get }
    var description: String? { get }
    var gameVersion: GameVersion { get }
    var mapLocationType: MapLocationType { get }

    var mapLocationPoint: MapLocationPoint? { get set }
    var inMapId: String? { get set }
    var inMissionId: String? { get set }
    var sortIndex: Int { get set }

    var annotationNote: String? { get set }

    var unavailabilityMessages: [String] { get set }

    var isHidden: Bool { get set }
    var isAvailable: Bool { get set }

// MARK: Optional
    var searchableName: String { get set }
    var linkToMapId: String? { get set }
    var shownInMapId: String? { get set }
    var isShowInParentMap: Bool { get set }
    var isShowInList: Bool { get set }
    var isShowPin: Bool { get set }
    var isOpensDetail: Bool { get set }
}

extension DataMapLocationable {
    public var searchableName: String { get { return name } set {} }
    public var linkToMapId: String? { get { return nil } set {} }
    public var shownInMapId: String? { get { return nil } set {} }
    public var isShowInParentMap: Bool { get { return false } set {} }
    public var isShowInList: Bool { get { return true } set {} }
    public var isShowPin: Bool { get { return false } set {} }
    public var isOpensDetail: Bool { get { return false } set {} }

    public func isEqual(_ mapLocation: DataMapLocationable) -> Bool {
        return id == mapLocation.id
            && gameVersion == mapLocation.gameVersion
            && mapLocationType == mapLocation.mapLocationType
    }
}

// MARK: Serializable Utilities
//extension DataMapLocationable {
//    /// Fetch MapLocationable values from a remote dictionary.
//    public mutating func unserializeMapLocationableData(_ data: [String: Any?]) {
//        createdDate = data["createdDate"] as? Date ?? createdDate
//        modifiedDate = data["modifiedDate"] as? Date ?? modifiedDate
//    }
//}
extension DataMapLocationable where Self: Codable {
    /// Fetch MapLocationable values from a Codable dictionary.
    public mutating func unserializeMapLocationableData(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DataMapLocationableCodingKeys.self)
        mapLocationPoint = (try container.decodeIfPresent(MapLocationPoint.self, forKey: .mapLocationPoint))
        inMapId = (try container.decodeIfPresent(String.self, forKey: .inMapId))
        inMissionId = (try container.decodeIfPresent(String.self, forKey: .inMissionId))
        sortIndex = (try container.decodeIfPresent(Int.self, forKey: .sortIndex)) ?? sortIndex
        annotationNote = (try container.decodeIfPresent(String.self, forKey: .annotationNote))
        unavailabilityMessages = (try container.decodeIfPresent(
            [String].self,
            forKey: .unavailabilityMessages
        )) ?? unavailabilityMessages
        isHidden = (try container.decodeIfPresent(Bool.self, forKey: .isHidden)) ?? isHidden
        isAvailable = (try container.decodeIfPresent(Bool.self, forKey: .isAvailable)) ?? isAvailable

        searchableName = try container.decodeIfPresent(String.self, forKey: .searchableName) ?? searchableName
        linkToMapId = try container.decodeIfPresent(String.self, forKey: .linkToMapId)
        shownInMapId = try container.decodeIfPresent(String.self, forKey: .shownInMapId)
        isShowInParentMap = (try container.decodeIfPresent(Bool.self, forKey: .isShowInParentMap)) ?? isShowInParentMap
        isShowInList = (try container.decodeIfPresent(Bool.self, forKey: .isShowInList)) ?? isShowInList
        isShowPin = (try container.decodeIfPresent(Bool.self, forKey: .isShowPin)) ?? isShowPin
        isOpensDetail = (try container.decodeIfPresent(Bool.self, forKey: .isOpensDetail)) ?? isOpensDetail
    }
    /// Store MapLocationable values to a Codable dictionary.
    public func serializeMapLocationableData(encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DataMapLocationableCodingKeys.self)
        try container.encode(mapLocationPoint, forKey: .mapLocationPoint)
        try container.encode(inMapId, forKey: .inMapId)
        try container.encode(inMissionId, forKey: .inMissionId)
        try container.encode(sortIndex, forKey: .sortIndex)
        try container.encode(annotationNote, forKey: .annotationNote)
        try container.encode(unavailabilityMessages, forKey: .unavailabilityMessages)
        try container.encode(isHidden, forKey: .isHidden)
        try container.encode(isAvailable, forKey: .isAvailable)
        try container.encode(searchableName, forKey: .searchableName)
        try container.encode(linkToMapId, forKey: .linkToMapId)
        try container.encode(shownInMapId, forKey: .shownInMapId)
        try container.encode(isShowInParentMap, forKey: .isShowInParentMap)
        try container.encode(isShowInList, forKey: .isShowInList)
        try container.encode(isShowPin, forKey: .isShowPin)
        try container.encode(isOpensDetail, forKey: .isOpensDetail)
    }
}

//extension DataMapLocationable where Self: CodableCoreDataStorable {
//    /// Save DateModifiable values to Core Data
//    public func setMapLocationableColumnsOnSave(coreItem: EntityType) {
//        coreItem.setValue(createdDate, forKey: "createdDate")
//        coreItem.setValue(modifiedDate, forKey: "modifiedDate")
//    }
//}

/// Codable keys for objects adhering to DateModifiable
public enum DataMapLocationableCodingKeys: String, CodingKey {
    case mapLocationPoint
    case inMapId
    case inMissionId
    case sortIndex
    case annotationNote
    case unavailabilityMessages
    case isHidden
    case isAvailable

    case searchableName
    case linkToMapId
    case shownInMapId
    case isShowInParentMap
    case isShowInList
    case isShowPin
    case isOpensDetail
}

