//
//  DataItems.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension DataItem: DataRowStorable, DataEventsable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = DataItems

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
		coreItem.id = id
		coreItem.name = name
		coreItem.inMapId = inMapId
		coreItem.isShowInList = isShowInList ? 1: 0
		coreItem.inMissionId = inMissionId
		coreItem.gameVersion = gameVersion.stringValue
		coreItem.relatedEvents = getRelatedDataEvents(context: coreItem.managedObjectContext)
//        coreItem.setValue(itemType.stringValue, forKey: "itemType")
	}
}
