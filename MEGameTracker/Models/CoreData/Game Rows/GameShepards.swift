//
//  GameShepards.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/31/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Shepard: SimpleSerializedCoreDataStorable {

    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Type of the core data entity.
    public typealias EntityType = GameShepards
    
    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Sets core data values to match struct values (specific).
    public func setAdditionalColumnsOnSave(
        coreItem: EntityType
    ) {
        setDateModifiableColumnsOnSave(coreItem: coreItem)
        coreItem.uuid = uuid
        coreItem.gameSequenceUuid = gameSequenceUuid
        coreItem.gameVersion = gameVersion.stringValue
        coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
    }
    
    /// (SimpleSerializedCoreDataStorable Protocol)
    /// Alters the predicate to retrieve only the row equal to this object.
    public func setIdentifyingPredicate(
        fetchRequest: NSFetchRequest<EntityType>
    ) {
        fetchRequest.predicate = NSPredicate(
            format: "(%K == %@)",
            #keyPath(GameShepards.uuid), uuid
        )
    }
}

// MARK: Utilities
extension Shepard {

    /// The closure type for editing fetch requests.
    /// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
    public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>)->Void)

// MARK: Save

    /// Save if there were changes, cascade save if so specified, delay save to interval timer by default.
    public mutating func saveAnyChanges(
        isCascadeChanges: EventDirection = .up,
        isAllowDelay: Bool = true,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Bool {
        if hasUnsavedChanges {
            if isAllowDelay {
                App.current.hasUnsavedChanges = true
                return true // not an error
            } else {
                let isSaved = save(isCascadeChanges: isCascadeChanges, isAllowDelay: false, with: manager)
                return isSaved
            }
        }
        return true
    }
    
    /// Save the game value, cascade save if so specified, delaying for interval timer by default.
    public mutating func save(
        isCascadeChanges: EventDirection,
        isAllowDelay: Bool,
        with manager: SimpleSerializedCoreDataManageable?
    ) -> Bool {
        hasUnsavedChanges = true // force this
        if isAllowDelay {
            App.current.hasUnsavedChanges = true
            return true // not an error
        }
        let manager = manager ?? defaultManager
        if isCascadeChanges != .none && isCascadeChanges != .down {
            if !GamesDataBackup.current.isSyncing {
                saveCommonDataToAllShepardsInSequence(with: manager)
                if isCascadeChanges == .up {
                    if var game = App.current.game?.uuid == gameSequenceUuid ? App.current.game : GameSequence.get(uuid: gameSequenceUuid) {
                        game.markChanged()
                        _ = game.save(isCascadeChanges: .up, isAllowDelay: false, with: manager)
                    }
                }
            }
        }
        let isSaved = manager.saveValue(item: self)
        if isSaved {
            hasUnsavedChanges = false
        }
        return isSaved
    }
    
    /// Convenience version of save:isCascadeChanges:isAllowDelay:manager (no manager required)
    public mutating func save(
        isCascadeChanges: EventDirection = .up,
        isAllowDelay: Bool
    ) -> Bool {
        return save(isCascadeChanges: isCascadeChanges, isAllowDelay: isAllowDelay, with: nil)
    }
    
    /// (SimpleSerializedCoreDataStorable Protocol override)
    public mutating func save(
        with manager: SimpleSerializedCoreDataManageable?
    ) -> Bool {
        return save(isCascadeChanges: .up, isAllowDelay: true, with: manager)
    }
    
    /// Convenience - no isAllowDelay required
    public mutating func save(
        isCascadeChanges: EventDirection,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Bool {
        return save(isCascadeChanges: isCascadeChanges, isAllowDelay: true, with: manager)
    }
    
    /// Certain properties are constant to all shepards within a given game, 
    ///   so when one is changed, change the other game version shepards to match.
    public mutating func saveCommonDataToAllShepardsInSequence(
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) {
        let gameSequenceUuid = self.gameSequenceUuid
        let uuid = self.uuid
        let manager = manager ?? defaultManager
        let shepards = Shepard.getAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@ and %K != %@)",
                #keyPath(GameShepards.gameSequenceUuid), gameSequenceUuid,
                #keyPath(GameShepards.uuid), uuid
            )
        }
        let commonData = getData()
        var isSaved = true
        for var sequenceShepard in shepards {
            if sequenceShepard.uuid != uuid {
                sequenceShepard.setCommonData(commonData)
                isSaved = isSaved && sequenceShepard.saveAnyChanges(isCascadeChanges: .none, isAllowDelay: false, with: manager)
            }
        }
        hasUnsavedChanges = !isSaved // sequence save
    }
    
// MARK: Delete

    /// Delete the value matching the ids specified.
    /// (Only ever called by cloudkit when syncing - deleting via GameSequence uses deleteAll().)
    public static func delete(
        uuid: String,
        gameSequenceUuid: String,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Bool {
        return deleteAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(GameShepards.uuid), uuid
            )
        }
    }
    
    /// Delete the game values for the specified game.
    /// (Only ever called by GameSequence, so does not bother notifying cloud for sync)
    public static func deleteAll(
        gameSequenceUuid: String,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Bool {
        let alterFetchRequest: AlterFetchRequest<EntityType> = { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(GameShepards.gameSequenceUuid), gameSequenceUuid
            )
        }
        Shepard.getAllIds(with: manager, alterFetchRequest: alterFetchRequest).forEach { (shepardUuid: String) in
            // delete any dependent photos
            DispatchQueue.global(qos: .background).async {
                _ = Shepard.deletePhoto(uuid: shepardUuid)
            }
        }
        // don't have to notify or cascade: GameSequence did that for you
        return deleteAll(with: manager, alterFetchRequest: alterFetchRequest)
    }
    
    // You can't individually delete Shepards, except through cloudkit. So we don't need delete() or notifyDeleteToCloud()
    
    
// MARK: Additional Convenience Methods

    /// Get a shepard by id.
    public static func get(
        uuid: String,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Shepard? {
        return get(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(GameShepards.uuid), uuid
            )
        }
    }
    
    /// Get the shepard for a specified game version for a given game.
    public static func get(
        gameVersion: GameVersion,
        gameSequenceUuid: String?,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Shepard? {
        return get(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(gameVersion == %@ AND gameSequenceUuid == %@)", gameVersion.stringValue, gameSequenceUuid ?? "")
        }
    }
    

    /// Get all shepards with ids.
    public static func getAll(
        uuids: [String],
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> [Shepard] {
        return getAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K in %@)",
                #keyPath(GameShepards.uuid), uuids
            )
        }
    }
    
    /// Get all the shepards for a given game.
    public static func getAll(
        gameSequenceUuid: String?,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> [Shepard] {
        return getAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(
                format: "(%K == %@)",
                #keyPath(GameShepards.gameSequenceUuid), gameSequenceUuid ?? ""
            )
        }
    }
    
    /// Get all matching shepard ids.
    public static func getAllIds(
        with manager: SimpleSerializedCoreDataManageable? = nil,
        alterFetchRequest: @escaping AlterFetchRequest<EntityType> = { _ in }
    ) -> [String] {
        let manager = manager ?? defaultManager
        var result: [String] = []
        autoreleasepool {
            result = manager.getAllTransformed(
                transformEntity: { $0.value(forKey: "uuid") as? String },
                alterFetchRequest: alterFetchRequest
            )
        }
        return result
    }
    
    /// Get shepard of a specified game with most recent modifiedDate.
    /// This is only called if game fails to save/load the current game (which is an error, but... during development, it happens).
    public static func lastPlayed(
        gameSequenceUuid: String,
        with manager: SimpleSerializedCoreDataManageable? = nil
    ) -> Shepard? {
        return get(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid == %@)", gameSequenceUuid)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "modifiedDate", ascending: false),
                NSSortDescriptor(key: "gameVersion", ascending: false)
            ]
        }
    }
    
    /// Delete the photo for the specified shepard.
    public static func deletePhoto(
        uuid: String
    ) -> Bool {
        let filename = Shepard.getPhotoFileNameIdentifier(uuid: uuid)
        if let photo = Photo(filePath: filename) {
            return photo.delete()
        }
        return false
    }
}
