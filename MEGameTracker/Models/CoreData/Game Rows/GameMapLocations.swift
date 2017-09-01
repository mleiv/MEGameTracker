//
//  GameMapLocation.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension MapLocation {

	/// Get location from id of a specified type in a specified game version.
	public static func get(
		id: String,
		type: MapLocationType,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> MapLocationable? {
		switch type {
		case .map:
			return Map.get(id: id, with: manager)
		case .mission:
			return Mission.get(id: id, with: manager)
		case .item:
			return Item.get(id: id, with: manager)
		}
	}

	/// Get all locations in a given map in a specified game version.
	public static func getAll(
		inMapId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return getAllMaps(inMapId: inMapId, gameVersion: gameVersion, with: manager)
			+ getAllMissions(inMapId: inMapId, gameVersion: gameVersion, with: manager)
			+ getAllItems(inMapId: inMapId, gameVersion: gameVersion, with: manager)
	}

	/// Get all locations in a given map in a specified game version.
	public static func getAll(
		inMissionId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return getAllMaps(inMissionId: inMissionId, gameVersion: gameVersion, with: manager)
			+ getAllMissions(inMissionId: inMissionId, with: manager)
			+ getAllItems(inMissionId: inMissionId, with: manager)
	}

	/// Get all maps in a given map in a specified game version.
	public static func getAllMaps(
		inMapId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Map.getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(inMapId = %@)", inMapId)
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all maps in a given mission in a specified game version.
	public static func getAllMaps(
		inMissionId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Map.getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(inMissionId = %@)", inMissionId)
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all missions in a given map in a specified game version.
	public static func getAllMissions(
		inMapId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Mission.getAllFromData(with: manager) { fetchRequest in
			if let gameVersion = gameVersion {
				fetchRequest.predicate = NSPredicate(
					format: "(inMapId = %@ AND gameVersion = %@)",
					inMapId, gameVersion.stringValue
				)
			} else {
				fetchRequest.predicate = NSPredicate(
					format: "(inMapId = %@)",
					inMapId
				)
			}
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all missions under a given mission.
	public static func getAllMissions(
		inMissionId: String,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Mission.getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(inMissionId = %@)", inMissionId)
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all items in a given map in a specified game version.
	public static func getAllItems(
		inMapId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
        return Item.getAllFromData(with: manager) { fetchRequest in
            if let gameVersion = gameVersion {
                fetchRequest.predicate = NSPredicate(
                    format: "(inMapId = %@ AND gameVersion = %@)",
                    inMapId, gameVersion.stringValue
                )
            } else {
                fetchRequest.predicate = NSPredicate(format: "(inMapId = %@)", inMapId)
            }
        }.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all items in a given mission.
	public static func getAllItems(
		inMissionId: String,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
        return Item.getAllFromData(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMissionId = %@)", inMissionId)
        }.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all maps matching a name in a specified game version limited by amount specified.
	public static func getAllMaps(
		likeName name: String,
		limit: Int = App.current.searchMaxResults,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Map.getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(name CONTAINS[cd] %@ AND isShowInList = true)",
				name
			)
			fetchRequest.fetchLimit = limit
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all missions matching a name in a specified game version limited by amount specified.
	public static func getAllMissions(
		likeName name: String,
		limit: Int = App.current.searchMaxResults,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return Mission.getAllFromData(with: manager) { fetchRequest in
			if let gameVersion = gameVersion {
				fetchRequest.predicate = NSPredicate(
					format: "(name CONTAINS[cd] %@ AND gameVersion = %@ AND isShowInList = true)",
					name, gameVersion.stringValue
				)
			} else {
				fetchRequest.predicate = NSPredicate(
					format: "(name CONTAINS[cd] %@ AND isShowInList = true)",
					name
				)
			}
			fetchRequest.fetchLimit = limit
		}.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Get all items matching a name in a specified game version limited by amount specified.
	public static func getAllItems(
		likeName name: String,
		limit: Int = App.current.searchMaxResults,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
        return Item.getAllFromData(with: manager) { fetchRequest in
            if let gameVersion = gameVersion {
                fetchRequest.predicate = NSPredicate(
                    format: "(name CONTAINS[cd] %@ AND gameVersion = %@ AND isShowInList = true)",
                    name, gameVersion.stringValue
                )
            } else {
                fetchRequest.predicate = NSPredicate(
                    format: "(name CONTAINS[cd] %@ AND isShowInList = true)",
                    name
                )
            }
            fetchRequest.fetchLimit = limit
        }.filter({ !$0.isHidden }).map { $0 as MapLocationable }
	}

	/// Assemble all child locations of a set of locations.
	public static func addChildMapLocations(mapLocations: [MapLocationable]) -> [MapLocationable] {
		// include sub missions and sub items, but change their location point to their parent
		var allChildMapLocations: [MapLocationable] = []
		for mapLocation in mapLocations {
			var childMapLocations: [MapLocationable] = []
			if mapLocation.mapLocationType == .map {
				childMapLocations += MapLocation.getAllMissions(
					inMapId: mapLocation.id,
					gameVersion: App.current.gameVersion
				)
				childMapLocations += MapLocation.getAllItems(
					inMapId: mapLocation.id,
					gameVersion: App.current.gameVersion
				)
				for (index, _) in childMapLocations.enumerated() {
					childMapLocations[index].mapLocationPoint = mapLocation.mapLocationPoint
					childMapLocations[index].mapLocationPoint?.radius = 1
				}
				allChildMapLocations += childMapLocations
			}
		}
		return mapLocations + allChildMapLocations
	}

}
