//
//  CoreDataManager.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/30/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.

import CoreData

/// Manages the storage and retrieval of CoreDataStorable/SerializableData objects.
import CoreData

struct CoreDataManager: SimpleSerializedCoreDataManageable {

    public static let defaultStoreName = "CoreData"
    
    public static var current: SimpleSerializedCoreDataManageable = CoreDataManager(storeName: defaultStoreName)

    public static var isManageMigrations: Bool = true // we manage migrations
    
    public var isConfinedToMemoryStore: Bool
    public let storeName: String
    public let persistentContainer: NSPersistentContainer
    public let specificContext: NSManagedObjectContext?
    
    public init() {
        self.init(storeName: CoreDataManager.defaultStoreName)
    }
    
    public init(storeName: String?, context: NSManagedObjectContext?, isConfineToMemoryStore: Bool) {
        self.isConfinedToMemoryStore = isConfineToMemoryStore
        self.storeName = storeName ?? CoreDataManager.defaultStoreName
        self.specificContext = context
        if let storeName = storeName {
            self.persistentContainer = NSPersistentContainer(name: storeName)
            initContainer(isConfineToMemoryStore: isConfineToMemoryStore)
        } else {
            persistentContainer = CoreDataManager.current.persistentContainer
        }
    }
    
    public func runMigrations(storeUrl: URL) {
        do {
            try CoreDataStructuralMigrations(storeName: storeName, storeUrl: storeUrl).run()
        } catch {
            fatalError("Could not run migrations \(error)")
        }
    }
}

extension SimpleSerializedCoreDataStorable {
    public static var defaultManager: SimpleSerializedCoreDataManageable {
        return CoreDataManager.current
    }
}
