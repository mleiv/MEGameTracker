//
//  DataEvent.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct DataEvent: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case description
        case isAlert
        case isAny
        case eraseParentValue
        case dependentOn
        case actions
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public internal(set) var id: String
	public internal(set) var gameVersion: GameVersion?
	public var description: String?

	public var isAlert = false
	public var eraseParentValue = false
    public var isAny: String?
	public var dependentOn: DependentOnType?
	public var actions: [Action] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Initialization
	public init(id: String) {
		self.id = id
		isDummyData = true
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameVersion = try container.decodeIfPresent(GameVersion.self, forKey: .gameVersion)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isAlert = try container.decodeIfPresent(Bool.self, forKey: .isAlert) ?? isAlert
        isAny = try container.decodeIfPresent(String.self, forKey: .isAny)
        eraseParentValue = try container.decodeIfPresent(Bool.self, forKey: .eraseParentValue) ?? eraseParentValue
        dependentOn = try container.decodeIfPresent(DependentOnType.self, forKey: .dependentOn)
        actions = try container.decodeIfPresent([Action].self, forKey: .actions) ?? actions
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(description, forKey: .description)
        try container.encode(isAlert, forKey: .isAlert)
        try container.encode(isAny, forKey: .isAny)
        try container.encode(eraseParentValue, forKey: .eraseParentValue)
        try container.encode(dependentOn, forKey: .dependentOn)
        try container.encode(actions, forKey: .actions)
    }
}

//// MARK: SerializedDataStorable
//extension DataEvent: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralData
//    }
//
//}

//// MARK: SerializedDataRetrievable
//extension DataEvent: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, let id = data["id"]?.string else { return nil }
//        let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
//
//        self.init(id: id, gameVersion: gameVersion, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
//
//        description = data["description"]?.string
//        eraseParentValue = data["eraseParentValue"]?.bool ?? eraseParentValue
//        isAlert = data["isAlert"]?.bool ?? isAlert
//        actions = (data["actions"]?.array ?? []).map({ Action(data: $0) }).filter({ $0 != nil }).map({ $0! })
//        dependentOn = DependentOnType(data: data["dependentOn"])
//    }
//
//}

// MARK: Equatable
extension DataEvent: Equatable {
	public static func == (_ lhs: DataEvent, _ rhs: DataEvent) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataEvent: Hashable {
	public var hashValue: Int { return id.hashValue }
}
