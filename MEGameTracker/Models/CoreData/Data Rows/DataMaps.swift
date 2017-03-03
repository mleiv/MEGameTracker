//
//  DataMap.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension DataMap: DataRowStorable, DataEventsable {

    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Type of the core data entity.
    public typealias EntityType = DataMaps
    
    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Sets core data values to match struct values (specific).
    public func setAdditionalColumnsOnSave(
        coreItem: EntityType
    ) {
        // only save searchable columns
        coreItem.id = id
        coreItem.name = name
        coreItem.inMapId = inMapId
        coreItem.isShowInList = isShowInList ? 1: 0
        coreItem.isMain = isMain ? 1 : 0
        coreItem.relatedEvents = getRelatedDataEvents(context: coreItem.managedObjectContext)
    }
}

extension DataMap {

    /// The closure type for editing fetch requests.
    /// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
    public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>)->Void)
    
    public static func get(
        id: String,
        gameVersion: GameVersion? = nil,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> DataMap? {
        let one: DataMap? = get(gameVersion: gameVersion, with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(DataMaps.id), id
            )
        }
        return one
    }
    
    public static func get(
        gameVersion: GameVersion?,
        with manager: SimpleSerializedCoreDataManageable? = nil,
        alterFetchRequest: @escaping AlterFetchRequest<EntityType>
    ) -> DataMap? {
        var one: DataMap? = get(with: manager, alterFetchRequest: alterFetchRequest)
        if let gameVersion = gameVersion {
            one?.change(gameVersion: gameVersion)
        }
        return one
    }
    
    public static func getAll(
        gameVersion: GameVersion?,
        with manager: SimpleSerializedCoreDataManageable? = nil,
        alterFetchRequest: @escaping AlterFetchRequest<EntityType>
    ) -> [DataMap] {
        var all: [DataMap] = getAll(with: manager, alterFetchRequest: alterFetchRequest)
        if let gameVersion = gameVersion {
            all = all.map { var m = $0; m.change(gameVersion: gameVersion); return m }
        }
        return all
    }
}
