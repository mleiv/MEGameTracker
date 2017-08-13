//
//  DataDecision.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct DataDecision {

	public typealias DependsOnDecisionValueType = (id: String, value: Bool)

// MARK: Constants

// MARK: Properties

	internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

	public fileprivate(set) var id: String
	public fileprivate(set) var gameVersion: GameVersion
	public var name: String = "Unknown"
	public var description: String?

	public var loveInterestId: String?
	public var sortIndex: Int = 0
	public var blocksDecisionIds: [String] = []
	public var dependsOnDecisions: [DependsOnDecisionValueType] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Initialization
	public init(id: String, gameVersion: GameVersion, data: SerializableData) {
		self.id = id
		self.gameVersion = gameVersion
		self.rawGeneralData = data

		setData(data)
	}
}

// MARK: SerializedDataStorable
extension DataDecision: SerializedDataStorable {

	public func getData() -> SerializableData {
		return rawGeneralData
	}

}

// MARK: SerializedDataRetrievable
extension DataDecision: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data, let id = data["id"]?.string,
			  let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
		else { return nil }

		self.init(id: id, gameVersion: gameVersion, data: data)
	}

	public mutating func setData(_ data: SerializableData) {
		id = data["id"]?.string ?? id
		gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
		name = data["name"]?.string ?? name

		description = data["description"]?.string
		loveInterestId = data["loveInterestId"]?.string
		sortIndex = data["sortIndex"]?.int ?? 0

		blocksDecisionIds = (data["blocksDecisionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
		dependsOnDecisions = (data["dependsOnDecisions"]?.array ?? []).map {
			if let id = $0["id"]?.string, let value = $0["value"]?.bool {
				return (id: id, value: value)
			}
			return nil
		}.filter({ $0 != nil }).map({ $0! })
	}
}

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
