//
//  GameMissions.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public typealias MissionStatusCounts = (total: Int, available: Int, unavailable: Int, completed: Int)

extension Mission: GameRowStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameMissions

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataMission

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.isCompleted = isCompleted ? 1 : 0
        coreItem.completedDate = completedDate
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable X Eventsable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Mission {
		var item = Mission(id: data.id, generalData: data)
        item.events = item.getEvents(gameSequenceUuid: item.gameSequenceUuid, with: manager)
		return item
	}

    /// (GameRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
        generalData.migrateId(id: newId)
    }
}

extension Mission {

// MARK: Additional Convenience Methods

	/// Get all missions from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataMissions.gameVersion), gameVersion.stringValue
			)
		}
	}

	/// Get all missions of the specified type from the specified game version.
	public static func getAllType(
		_ type: MissionType,
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K == %@) AND (%K == %@))",
				#keyPath(DataMissions.missionType), type.stringValue,
				#keyPath(DataMissions.gameVersion), gameVersion.stringValue
			)
		}
	}

	/// Get all recently viewed missions from the specified game version.
	public static func getAllRecent(
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		var missions: [Mission] = []
		let gameVersion = gameVersion ?? GameVersion.game1
		App.current.recentlyViewedMissions[gameVersion]?.contents.forEach {
			if var mission = Mission.get(id: $0.id, with: manager) {
				mission.modifiedDate = $0.date // hijack for date - won't be saved anyway
				missions.append(mission)
			}
		}
		return missions
	}

	/// Get all missions matching the name given from the specified game version, limited to the amount specified.
	public static func getAll(
		likeName name: String,
		limit: Int = App.current.searchMaxResults,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllFromData(with: manager) { fetchRequest in
			if let gameVersion = gameVersion {
				fetchRequest.predicate = NSPredicate(
					format: "(%K CONTAINS[cd] %@ AND %K == %@ AND %K == true)",
					#keyPath(DataMissions.name), name,
					#keyPath(DataMissions.gameVersion), gameVersion.stringValue,
					#keyPath(DataMissions.isShowInList)
				)
			} else {
				fetchRequest.predicate = NSPredicate(
					format: "(%K CONTAINS[cd] %@ AND %K == true)",
					#keyPath(DataMissions.name), name,
					#keyPath(DataMissions.isShowInList)
				)
			}
			fetchRequest.fetchLimit = limit
		}
	}

	/// Get all mission-type missions with the specified ids.
	public static func getAllMissions(
		ids: [String],
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		guard !ids.isEmpty else { return [] }
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K in %@)",
				#keyPath(DataMissions.id), ids
			)
		}
	}

	/// Get all mission-type missions from the specified game version.
	public static func getAllMissions(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllType(.mission, gameVersion: gameVersion, with: manager)
	}

	/// Get all assignment-type missions from the specified game version.
	public static func getAllAssignments(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllType(.assignment, gameVersion: gameVersion, with: manager)
	}

	/// Get all task-type missions from the specified game version.
	public static func getAllTasks(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Mission] {
		return getAllType(.task, gameVersion: gameVersion, with: manager)
	}

	/// Get all objectives from the specified mission.
	public static func getAllObjectives(
		underId id: String,
		with manager: CodableCoreDataManageable? = nil
	) -> [MapLocationable] {
		return MapLocation.getAll(inMissionId: id, with: manager)
	}

	/// Get a report on missions completed and not completed. No way currently to check availability.
	public static func getCountedMissionStatus(
		missionType: MissionType,
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> MissionStatusCounts {
		let availableCount = DataMission.getCount(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K == %@) AND (%K == %@))",
				#keyPath(DataMissions.missionType), missionType.stringValue,
				#keyPath(DataMissions.gameVersion), gameVersion.stringValue
			)
		}
        let totalCount = availableCount
		let unavailableCount = 0
		let completedCount = Mission.getCount(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K == %@) AND (%K == %@) AND (%K == true))",
				#keyPath(GameMissions.dataParent.missionType), missionType.stringValue,
				#keyPath(GameMissions.dataParent.gameVersion), gameVersion.stringValue,
				#keyPath(GameMissions.isCompleted)
			)
		}
		return (
            total: totalCount,
            available: totalCount - completedCount,
            unavailable: unavailableCount,
            completed: completedCount
        )
	}

    public static func getCompletedCount(
        after: Date,
        missionTypes: [MissionType] = [.mission],
        gameVersion: GameVersion = .game1,
        with manager: CodableCoreDataManageable? = nil
    ) -> Int {
        return Mission.getCount(with: nil) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "((%K in %@) AND (%K == %@) AND (%K == true) AND %K > %@)",
                #keyPath(GameMissions.dataParent.missionType),
                missionTypes.map { $0.stringValue },
                #keyPath(GameMissions.dataParent.gameVersion),
                gameVersion.stringValue,
                #keyPath(GameMissions.isCompleted),
                #keyPath(GameMissions.completedDate),
                after as NSDate
            )
        }
    }
}
