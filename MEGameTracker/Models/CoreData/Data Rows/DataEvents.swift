//
//  DataEvents.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension DataEvent: DataRowStorable {

    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Type of the core data entity.
    public typealias EntityType = DataEvents
    
    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Sets core data values to match struct values (specific).
    public func setAdditionalColumnsOnSave(
        coreItem: EntityType
    ) {
        // only save searchable columns
        coreItem.id = id
        coreItem.gameVersion = gameVersion?.stringValue
    }
}




