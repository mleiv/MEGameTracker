//
//  DataMap.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataMap: MapLocationable {
// MARK: Constants

// MARK: Properties

	public var gameVersionData = SerializableData()
	internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

	public fileprivate(set) var id: String
	public fileprivate(set) var gameVersion: GameVersion
	public var name: String = "Unknown"
	public var mapType: MapType = .location
	public var description: String?

	public var image: String?
	public var referenceSize: CGSize?
	public var isMain = false
	public var isSplitMenu = false
	public var rerootBreadcrumbs: Bool = false

	public internal(set) var isExplorable: Bool = false

	public fileprivate(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Map
	public fileprivate(set) var sideEffects: [String] = []
	public fileprivate(set) var relatedMissionIds: [String] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties

	public var rawEventData: SerializableData? {
		get { return rawGeneralData["events"] }
		set { rawGeneralData["events"] = newValue }
	}

// MARK: MapLocationable

	public var annotationNote: String?

	public var mapLocationType = MapLocationType.map
	public var mapLocationPoint: MapLocationPoint?
	public var inMapId: String?
	public var inMissionId: String?
	public var sortIndex = 0

	public var isHidden = false
	public var isAvailable: Bool = true
	public var unavailabilityMessages: [String] = []

//	public var searchableName: String // default
	public var linkToMapId: String?
	public var shownInMapId: String?
	public var isShowInParentMap = false
	public var isShowInList: Bool = true
	public var isShowPin: Bool = false
	public var isOpensDetail = true

// MARK: Initialization

	public init(id: String, gameVersion: GameVersion, data: SerializableData) {
		self.id = id
		self.gameVersion = gameVersion
		self.rawGeneralData = data

		rawEventData = data["events"]
		gameVersionData = data["gameVersionData"] ?? SerializableData()
		setGameVersionData()
	}

	internal mutating func setGameVersionData() {
		let gameVersionData = self.gameVersionData[gameVersion.stringValue] ?? SerializableData()

		isHidden = gameVersionData["isHidden"]?.bool ?? (rawGeneralData["isHidden"]?.bool ?? isHidden)

		name = gameVersionData["name"]?.string ?? (rawGeneralData["name"]?.string ?? name)
		if let gameDescription = gameVersionData["description"] { // allow nil override
			description = gameDescription.string
		} else {
			description = rawGeneralData["description"]?.string
		}

		mapType = MapType(stringValue: gameVersionData["mapType"]?.string
			?? rawGeneralData["mapType"]?.string) ?? mapType

		isMain = gameVersionData["isMain"]?.bool ?? (rawGeneralData["isMain"]?.bool ?? isMain)
		isSplitMenu = gameVersionData["isSplitMenu"]?.bool ?? (rawGeneralData["isSplitMenu"]?.bool ?? isSplitMenu)

		if let gameInMapId = gameVersionData["inMapId"] { // allow nil override
			inMapId = gameInMapId.string
		} else {
			inMapId = rawGeneralData["inMapId"]?.string
		}
		if let gameInMissionId = gameVersionData["inMissionId"] { // allow nil override
			inMissionId = gameInMissionId.string
		} else {
			inMissionId = rawGeneralData["inMissionId"]?.string
		}
		if let gameLinkToMapId = gameVersionData["linkToMapId"] { // allow nil override
			linkToMapId = gameLinkToMapId.string
		} else {
			linkToMapId = rawGeneralData["linkToMapId"]?.string
		}

		isShowInList = gameVersionData["isShowInList"]?.bool
			?? (rawGeneralData["isShowInList"]?.bool ?? isShowInList)
		isOpensDetail = gameVersionData["isOpensDetail"]?.bool
			?? (rawGeneralData["isOpensDetail"]?.bool ?? isOpensDetail)

		if let gameImage = gameVersionData["image"] { // allow nil override
			image = gameImage.string
		} else {
			image = rawGeneralData["image"]?.string
		}

		var referenceSize = rawGeneralData["referenceSize"]?.string
		if let gameSize = gameVersionData["referenceSize"] { // allow nil override
			referenceSize = gameSize.string
		}
		if let sizeString = referenceSize {
			let referenceSizeBits = sizeString.components(separatedBy: "x")
			if referenceSizeBits.count == 2 {
				if let w = NumberFormatter().number(from: referenceSizeBits[0]),
					let h = NumberFormatter().number(from: referenceSizeBits[1]) {
					self.referenceSize = CGSize(width: CGFloat(w), height: CGFloat(h))
				}
			}
		} else {
			self.referenceSize = nil
		}

		isShowPin = gameVersionData["isShowPin"]?.bool ?? (rawGeneralData["isShowPin"]?.bool ?? isShowPin)

		annotationNote = gameVersionData["annotationNote"]?.string
			?? (rawGeneralData["annotationNote"]?.string ?? annotationNote)

		if let pointData = gameVersionData["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
			self.mapLocationPoint = point
		} else if let pointData = rawGeneralData["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
			self.mapLocationPoint = point
		} else {
			self.mapLocationPoint = nil
		}

		rerootBreadcrumbs = gameVersionData["rerootBreadcrumbs"]?.bool
			?? (rawGeneralData["rerootBreadcrumbs"]?.bool ?? rerootBreadcrumbs)

		sortIndex = gameVersionData["sortIndex"]?.int ?? (rawGeneralData["sortIndex"]?.int ?? sortIndex)

		relatedLinks = ((gameVersionData["relatedLinks"]?.array
			?? rawGeneralData["relatedLinks"]?.array) ?? []).flatMap({ $0.string })
		relatedDecisionIds = ((gameVersionData["relatedDecisionIds"]?.array
			?? rawGeneralData["relatedDecisionIds"]?.array) ?? []).flatMap({ $0.string })
		sideEffects = ((gameVersionData["sideEffects"]?.array
			?? rawGeneralData["sideEffects"]?.array) ?? []).flatMap({ $0.string })
		relatedMissionIds = ((gameVersionData["relatedMissionIds"]?.array
			?? rawGeneralData["relatedMissionIds"]?.array) ?? []).flatMap({ $0.string })

		isExplorable = !isHidden
			&& !(inMapId?.isEmpty ?? true)
			&& mapType.isExplorable
			&& (gameVersionData["isExplorable"]?.bool
				?? (rawGeneralData["isExplorable"]?.bool
				?? true))
	}
}

// MARK: Retrieval Functions of Related Data
extension DataMap {

	public func getBreadcrumbs() -> [AbbreviatedMapData] {
		if isDummyData {
			return [
				AbbreviatedMapData(id: "0a", name: "Galaxy Map"), AbbreviatedMapData(id: "0b", name: "Omega Nebula")
			]
		}
		if !rerootBreadcrumbs,
			let parentMapId = self.inMapId,
			let parent = DataMap.get(id: parentMapId, gameVersion: gameVersion) {
			return parent.getBreadcrumbs() + [AbbreviatedMapData(id: parent.id, name: parent.name)]
		}
		return []
	}

	public func getCompleteBreadcrumbs() -> [AbbreviatedMapData] {
		if isDummyData {
			return [
				AbbreviatedMapData(id: "0a", name: "Galaxy Map"), AbbreviatedMapData(id: "0b", name: "Omega Nebula")
			]
		}
		if let parentMapId = self.inMapId,
			let parent = DataMap.get(id: parentMapId, gameVersion: gameVersion) {
			return parent.getCompleteBreadcrumbs() + [AbbreviatedMapData(id: parent.id, name: parent.name)]
		}
		return []
	}

	public func getInheritableEvents() -> [SerializableData] {
		let inheritableEvents: [SerializableData] = (rawEventData?.array ?? []).flatMap({
			if let eventType = EventType(stringValue: $0["type"]?.string),
				eventType.isAppliesToChildren {
				return $0
			}
			return nil
		})
		return inheritableEvents
	}
}

// MARK: Data Change Actions
extension DataMap {
	public mutating func change(gameVersion: GameVersion) {
		self.gameVersion = gameVersion
		setGameVersionData()
	}

}

// MARK: SerializedDataStorable
extension DataMap: SerializedDataStorable {

	public func getData() -> SerializableData {
		return rawGeneralData
		// note: ^ this means all in-app changes must be made to Event instead, or also change this value
	}

}

// MARK: SerializedDataRetrievable
extension DataMap: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data,
			let id = data["id"]?.string
		else { return nil }

		let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? .game1

		self.init(id: id, gameVersion: gameVersion, data: data)
	}

	public mutating func setData(_ data: SerializableData) {
		id = data["id"]?.string ?? id
		rawEventData = data["events"] ?? rawEventData
		if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
			self.gameVersion = gameVersion
		}
		for (key, value) in data.dictionary ?? [:] {
			// does not change rawGeneralData - will not persist to database
			gameVersionData[key] = value
		}
		setGameVersionData()
	}

}

// MARK: Equatable
extension DataMap: Equatable {
	public static func == (_ lhs: DataMap, _ rhs: DataMap) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataMap: Hashable {
	public var hashValue: Int { return id.hashValue }
}
