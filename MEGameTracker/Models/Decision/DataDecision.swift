//
//  DataDecision.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct DataDecision: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case name
        case description
        case loveInterestId
        case sortIndex
        case blocksDecisionIds
        case linkedEventIds
        case dependsOnDecisions
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public private(set) var id: String
	public private(set) var gameVersion: GameVersion
	public var name: String = "Unknown"
	public var description: String?

	public var loveInterestId: String?
	public var sortIndex: Int = 0
	public var blocksDecisionIds: [String] = []
    public var linkedEventIds: [String] = []
	public var dependsOnDecisions: [DependsOnDecisionValueType] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Initialization
    public init(id: String) {
        self.id = id
        self.gameVersion = .game1
        isDummyData = true
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameVersion = try container.decode(GameVersion.self, forKey: .gameVersion)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        loveInterestId = try container.decodeIfPresent(String.self, forKey: .loveInterestId)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex) ?? sortIndex
        blocksDecisionIds = try container.decodeIfPresent(
            [String].self,
            forKey: .blocksDecisionIds
        ) ?? blocksDecisionIds
        linkedEventIds = try container.decodeIfPresent(
            [String].self,
            forKey: .linkedEventIds
        ) ?? linkedEventIds
        dependsOnDecisions = try container.decodeIfPresent(
            [DependsOnDecisionValueType].self,
            forKey: .dependsOnDecisions
        ) ?? dependsOnDecisions
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(description, forKey: .description)
        try container.encode(loveInterestId, forKey: .loveInterestId)
        try container.encode(sortIndex, forKey: .sortIndex)
        try container.encode(blocksDecisionIds, forKey: .blocksDecisionIds)
        try container.encode(linkedEventIds, forKey: .linkedEventIds)
        try container.encode(dependsOnDecisions, forKey: .dependsOnDecisions)
    }
}

//// MARK: SerializedDataStorable
//extension DataDecision: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralData
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension DataDecision: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, let id = data["id"]?.string,
//              let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
//        else { return nil }
//
//        self.init(id: id, gameVersion: gameVersion, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
//        name = data["name"]?.string ?? name
//
//        description = data["description"]?.string
//        loveInterestId = data["loveInterestId"]?.string
//        sortIndex = data["sortIndex"]?.int ?? 0
//
//        blocksDecisionIds = (data["blocksDecisionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        dependsOnDecisions = (data["dependsOnDecisions"]?.array ?? []).map {
//            if let id = $0["id"]?.string, let value = $0["value"]?.bool {
//                return (id: id, value: value)
//            }
//            return nil
//        }.filter({ $0 != nil }).map({ $0! })
//    }
//}

// MARK: Equatable
extension DataDecision: Equatable {
	public static func == (_ lhs: DataDecision, _ rhs: DataDecision) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataDecision: Hashable {
	public var hashValue: Int { return id.hashValue }
}
