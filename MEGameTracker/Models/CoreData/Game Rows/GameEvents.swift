//
//  GameEvents.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Event: GameRowStorable {
	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameEvents

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataEvent

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem)
		coreItem.id = id
        coreItem.gameVersion = gameVersion?.stringValue
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
        coreItem.isTriggered = isTriggered ? 1 : 0
        coreItem.triggeredDate = triggeredDate
        coreItem.isAny = isAny
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Event {
		return Event(id: data.id, generalData: data)
	}

    /// (GameRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
        generalData.migrateId(id: newId)
    }
}

extension Event {

// MARK: Additional Convenience Methods

	/// Get all events from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K == %@) OR (%K == nil))",
				#keyPath(DataEvents.gameVersion), gameVersion.stringValue,
				#keyPath(DataEvents.gameVersion)
			)
		}
	}

	/// Get an event by id, and assign it a specific type.
	public static func get(
		id: String?,
		type: EventType,
        gameSequenceUuid: UUID? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> Event? {
		guard let id = id, !id.isEmpty else { return nil }
        var one = get(id: id, gameSequenceUuid: gameSequenceUuid, with: manager)
		one?.type = type
		return one
	}

	/// Return all events dependent on level score. This depends on the event being properly named.
	public static func getLevels(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				"id", "Level \\d+",
				"gameVersion", gameVersion.stringValue
			)
		}
	}

	/// Return all events dependent on paragon score. This depends on the event being properly named.
	public static func getParagons(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				"id", "%Paragon \\d+",
                "gameVersion", gameVersion.stringValue
			)
		}
	}

	/// Return all events dependent on renegade score. This depends on the event being properly named.
	public static func getRenegades(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				"id", "%Renegade \\d+",
				"gameVersion", gameVersion.stringValue
			)
		}
	}

    // return all events with any mission triggers
    public static func getTypeAnyMission(
        gameSequenceUuid: UUID,
        with manager: CodableCoreDataManageable? = nil
    ) -> [Event] {
        return getAllFromData(
            gameSequenceUuid: gameSequenceUuid
        ) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(DataEvents.isAny), BaseDataFileImportType.mission.stringValue
            )
        }
    }

	/// Get all ids of a given type related to the event specified.
	public static func getAffectedIds<T: CodableCoreDataStorable>(
		ofType type: T.Type,
		relatedToEvent event: Event,
		with manager: CodableCoreDataManageable? = nil
	) -> [String] {
        let manager = manager ?? defaultManager
        var result: [String] = []
        autoreleasepool {
            result = manager.getAllTransformed(
                transformEntity: { $0.value(forKey: "id") as? String },
                alterFetchRequest: { (fetchRequest: NSFetchRequest<T.EntityType>) in
                    fetchRequest.predicate = NSPredicate(
                        format: "(ANY relatedEvents.id == %@)",
                        event.id
                    )
                }
            )
        }
        return result
    }

// MARK: Copy

    /// Copy the event to a new game
    public static func copyAll(
        in gameVersions: [GameVersion],
        sourceUuid: UUID,
        destinationUuid: UUID,
        with manager: CodableCoreDataManageable?
        ) -> Bool {
        return copyAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(gameVersion in %@ and gameSequenceUuid == %@)",
                gameVersions.map({ $0.stringValue }),
                sourceUuid.uuidString)
        }, setChangedValues: { nsManagedObject in
            nsManagedObject.setValue(destinationUuid.uuidString, forKey: "gameSequenceUuid")
            if let data = nsManagedObject.value(forKey: serializedDataKey) as? Data,
                var item = try? defaultManager.decoder.decode(Event.self, from: data) {
                item.gameSequenceUuid = destinationUuid
                if let data2 = try? defaultManager.encoder.encode(item) {
                    nsManagedObject.setValue(data2, forKey: serializedDataKey)
                }
            }
        })
    }
}
