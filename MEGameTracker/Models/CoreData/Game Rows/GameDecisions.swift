//
//  GameDecisions.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Decision: GameRowStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameDecisions

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataDecision

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.isSelected = isSelected ? 1 : 0
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using generalData: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Decision {
		return Decision(id: generalData.id, generalData: generalData)
	}
}

extension Decision {

// MARK: Additional Convenience Methods

	/// Get all decisions from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Decision] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataDecisions.gameVersion), gameVersion.stringValue
			)
		}
	}
}
