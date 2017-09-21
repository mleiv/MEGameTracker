//
//  GameItems.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Item: GameRowStorable {

	/// (CodableCoreDataManageable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameItems

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataItem

	/// (CodableCoreDataManageable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.isAcquired = isAcquired ? 1 : 0
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable X Eventsable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Item {
		var item = Item(id: data.id, generalData: data)
		item.events = item.getEvents(with: manager)
		return item
	}

}

extension Item {

// MARK: Additional Convenience Methods

	/// Get all items from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Item] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataItems.gameVersion), gameVersion.stringValue
			)
		}
	}
}
