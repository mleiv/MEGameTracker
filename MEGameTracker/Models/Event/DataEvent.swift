//
//  DataEvent.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public struct DataEvent {
// MARK: Constants

// MARK: Properties

	internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

	public fileprivate(set) var id: String
	public fileprivate(set) var gameVersion: GameVersion?
	public var description: String?

	public var isAlert = false
	public var eraseParentValue = false
	public var dependentOn: DependentOnType?
	public var actions: [Action] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Initialization

	public init(id: String, gameVersion: GameVersion?, data: SerializableData) {
		self.id = id
		self.gameVersion = gameVersion
		self.rawGeneralData = data

		setData(data)
	}

	public init(id: String) {
		self.id = id
		isDummyData = true
	}
}

// MARK: SerializedDataStorable
extension DataEvent: SerializedDataStorable {

	public func getData() -> SerializableData {
		return rawGeneralData
	}

}

// MARK: SerializedDataRetrievable
extension DataEvent: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data, let id = data["id"]?.string else { return nil }
		let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")

		self.init(id: id, gameVersion: gameVersion, data: data)
	}

	public mutating func setData(_ data: SerializableData) {
		id = data["id"]?.string ?? id
		gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")

		description = data["description"]?.string
		eraseParentValue = data["eraseParentValue"]?.bool ?? eraseParentValue
		isAlert = data["isAlert"]?.bool ?? isAlert
		actions = (data["actions"]?.array ?? []).flatMap({ Action(data: $0) })
		dependentOn = DependentOnType(data: data["dependentOn"])
	}

}

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
