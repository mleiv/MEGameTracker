//
//  CloudDataStorable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

// swiftlint:disable file_length

/// A protocol for describing classes or structs that can be stored in core data AND cloudkit
public protocol CloudDataStorable {

// MARK: Required

	/// Cloud table names are same as core data. 
	/// (Default provided for CodableCoreDataStorable objects.)
	static var cloudRecordType: String { get }

	/// Core data identifying entity name.
	static var entityName: String { get }

	/// Flag for whether the local object has changes not saved to the cloud.
	/// This value is used for gathering local objects from the core data store.
	var isSavedToCloud: Bool { get set }

	/// A set of any changes to the local object since the last cloud sync.
	var pendingCloudChanges: CodableDictionary { get set }

	/// A copy of the last cloud kit record.
	var lastRecordData: Data? { get set }

	/// Create a recordName for any cloud kit object.
	func getIdentifyingName() -> String

	/// Set any additional fields, specific to the object in question, for a cloud kit object.
	func setAdditionalCloudFields(record: CKRecord)

	/// Alter any CK items before handing to codable to modify/create object
    func getAdditionalCloudFields(changeRecord: CloudDataRecordChange) -> [String: Any?]

	/// Set identifying fields for a cloud kit object. 
	/// (Default provided for GameRowStorable objects.)
	func setIdentifyingCloudFields(record: CKRecord)

	/// Set date fields for a cloud kit object. 
	/// (Default provided for DateModifiable objects.)
	func setDateModifiableCloudFields(record: CKRecord)

	/// Get all objects to be saved to cloud. 
	/// (Default provided for CodableCoreDataStorable objects.)
	static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: CodableCoreDataManageable?
	) -> [CKRecord]

	/// Delete a local object after directed by the cloud to do so. 
	/// (Default provided for GameRowStorable objects.)
	static func deleteOneFromCloud(recordId: String) -> Bool

// MARK: Optional

	/// A reference to the current cloud kit manager.
	static var defaultManager: SimpleCloudKitManageableConforming { get set }

	/// Create a consistent record id for any cloud kit object.
	func getRecordId() -> CKRecord.ID

	/// Create a consistent record id based on a provided recordName.
	static func getRecordId(
		recordName: String
	) -> CKRecord.ID

	/// Save changed fields and mark local object as needing a cloud sync.
	mutating func notifySaveToCloud(fields: [String: Any?])

	/// Create a CKRecord and set all the fields to current values.
	func createSaveRecord() -> CKRecord

	/// Create a CKRecord object (based on object's last record object, if it is available).
	func createCKRecord() -> CKRecord

	/// Set relevant fields for a cloud kit object - DO NOT OVERRIDE.
	func setCloudFields(record: CKRecord)

	/// Any action on completion of a cloud save.
	static func confirmRecordSaved(
		record: CKRecord,
		with manager: CodableCoreDataManageable?
	)

	/// Create a delete object and flag local manager that we need a cloud sync.
	mutating func notifyDeleteToCloud()

	/// Get all objects to be deleted in cloud.
	static func getAllDeletesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: CodableCoreDataManageable?
	) -> [CKRecord.ID]

	/// Any action on completion of a cloud delete.
	static func confirmRecordIdDeleted(
		recordId: CKRecord.ID,
		with manager: CodableCoreDataManageable?
	)

	/// Takes a gathered set of serialized cloud changes and batch saves them.
	static func saveAllFromCloud(
		changes: [CloudDataRecordChange],
		with manager: CodableCoreDataManageable?
	) -> Bool

	/// Takes one serialized cloud change and saves it.
	static func saveOneFromCloud(
        changeRecord: CloudDataRecordChange,
		with manager: CodableCoreDataManageable?
	) -> Bool

	/// Translate a record object into a local serialized value for local batch save.
	static func serializeRecordSave(
		record: CKRecord
	) -> CloudDataRecordChange

	/// Translate a record object into a local serialized value for local batch delete.
	static func serializeRecordDelete(
		recordId: CKRecord.ID
	) -> CloudDataRecordChange
}

// default implementations for the protocol:
extension CloudDataStorable {

// MARK: Get

	/// (Protocol default)
	/// Create a consistent record id for any cloud kit object.
	public func getRecordId() -> CKRecord.ID {
		return CKRecord.ID(recordName: getIdentifyingName(), zoneID: GamesDataBackup.current.zoneId)
	}

	/// (Protocol default)
	/// Create a consistent record id based on a provided recordName.
	public static func getRecordId(
		recordName: String
	) -> CKRecord.ID {
		return CKRecord.ID(recordName: recordName, zoneID: GamesDataBackup.current.zoneId)
	}

// MARK: Save

	/// (Protocol default)
	/// Save changed fields and mark local object as needing a cloud sync.
	public mutating func notifySaveToCloud(
		fields: [String: Any?]
	) {
        guard !fields.isEmpty else { return }
		for (key, value) in fields {
			pendingCloudChanges[key] = value
		}
		isSavedToCloud = false
		Self.defaultManager.isPendingCloudChanges = true
	}

	/// Convenience - getAllSavesToCloud with no core data manager.
	public static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool = false
	) -> [CKRecord] {
		return getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: nil)
	}

	/// (Protocol default)
	/// Create a CKRecord and set all the fields to current values.
	public func createSaveRecord() -> CKRecord {
		let record = createCKRecord()
		setCloudFields(record: record)
		return record
	}

	/// (Protocol default)
	/// Create a CKRecord object (based on object's last record object, if it is available).
	public func createCKRecord() -> CKRecord {
		if let archivedData = lastRecordData,
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: archivedData) {
			unarchiver.requiresSecureCoding = true
			if let record = CKRecord(coder: unarchiver) {
				return record
			}
		}
		return CKRecord(recordType: Self.cloudRecordType, recordID: getRecordId())
	}

	/// (Protocol default)
	/// Set relevant fields for a cloud kit object - DO NOT OVERRIDE.
	public func setCloudFields(record: CKRecord) {
		setIdentifyingCloudFields(record: record)
		setDateModifiableCloudFields(record: record)
		setAdditionalCloudFields(record: record)
	}

	/// (Protocol default)
	/// Set identifiers for a cloud kit object. Default provided for GameRowStorable objects.
	public func setIdentifyingCloudFields(record: CKRecord) {}

	/// (Protocol default)
	/// Set date values for a cloud kit object. Default provided for DateModifiable objects.
	public func setDateModifiableCloudFields(record: CKRecord) {}

	/// (Protocol default)
	/// Any action on completion of a cloud save.
	public static func confirmRecordSaved(
		record: CKRecord,
		with manager: CodableCoreDataManageable?
	) {}

	/// (Protocol default)
	/// Takes a gathered set of serialized cloud changes and batch saves them.
	public static func saveAllFromCloud(
		changes: [CloudDataRecordChange],
		with manager: CodableCoreDataManageable?
	) -> Bool {
		guard !changes.isEmpty else { return true }
		var isSaved = true
		for change in changes {
            let recordId = change.recordId
			if change.isDeleted == true {
				if Self.deleteOneFromCloud(recordId: recordId) {
					print("Delete from cloud \(recordId)")
				} else {
					isSaved = false
					print("Delete from cloud failed \(recordId)")
				}
				continue
			}
			isSaved = saveOneFromCloud(changeRecord: change, with: manager)
		}
		return isSaved
	}

// MARK: Delete

	/// (Protocol default)
	/// Create a delete object and flag local manager that we need a cloud sync.
	public mutating func notifyDeleteToCloud() {
        var row = DeletedRow(source: Self.entityName, identifier: getIdentifyingName())
        _ = row.save()
		Self.defaultManager.isPendingCloudChanges = true
	}

	/// (Protocol default)
	/// Get all objects to be deleted in cloud.
	public static func getAllDeletesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: CodableCoreDataManageable?
	) -> [CKRecord.ID] {
		guard !isFullDatabaseCopy else { return [] }
		let source = Self.entityName
        let deletedRows = DeletedRow.getAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(source = %@)", source)
        }
		return deletedRows.map { $0.getRecordId(recordName: $0.identifier) }
	}

	/// (Protocol default)
	/// Any action on completion of a cloud delete.
	public static func confirmRecordIdDeleted(
		recordId: CKRecord.ID,
		with manager: CodableCoreDataManageable?
	) {
        _ = DeletedRow.delete(identifier: recordId.recordName, with: manager)
	}

// MARK: Serialize Records

	/// (Protocol default)
	/// Translate a record object into a local serialized value for local batch save.
	public static func serializeRecordSave(
		record: CKRecord
	) -> CloudDataRecordChange {
        var changes: [String: Any?] = [
            "lastRecordData": serializeLastRecordData(record: record),
        ]
        changes.merge(record.allKeys().map { key -> (String, Any?) in
            let value: Any? = {
                switch record[key] {
                case let v where v is NSNumber: return v as? Double
                case let v where v is NSString: return v as? String
                case let v where v is NSDate: return v as? Date
                case let v where v is NSArray:
                    return (v as? NSArray) as? [String]
                case let v where v is CKAsset:
                    if let v = v as? CKAsset,
                        let image = UIImage(contentsOfFile: v.fileURL.path) {
                        return GamesDataBackup.current.cacheImage(image, recordId: record.recordID.recordName, key: key)
                    }
                    fallthrough
                default: return nil
                }
            }()
            return (key, value)
        }) { (_, new) in return new }
        return CloudDataRecordChange(
            recordId: record.recordID.recordName,
            isDeleted: false,
            changeSet: changes,
            lastRecordData: Data()
        )
	}

	/// (Protocol default)
	/// Translate a record object into a local serialized value for local batch delete.
	public static func serializeRecordDelete(
		recordId: CKRecord.ID
	) -> CloudDataRecordChange {
        return CloudDataRecordChange(
            recordId: recordId.recordName,
            isDeleted: true,
            changeSet: [:],
            lastRecordData: Data()
        )
	}

	/// Translate a record object into a local serialized value, to be stored for later use.
	internal static func serializeLastRecordData(
		record: CKRecord
	) -> Data {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        record.encodeSystemFields(with: archiver)
        return archiver.encodedData
	}

}

// MARK: Extensions - Self: {Protocol}

// (Note: these protocols can't use Self or associatedType)
extension CloudDataStorable where Self: CodableCoreDataStorable {

	/// (CloudDataStorable x CodableCoreDataStorable Protocol)
	/// The cloudkit entity name for this object.
	public static var cloudRecordType: String { return entityName }

	/// (CloudDataStorable x CodableCoreDataStorable Protocol)
	/// Get all objects to be saved to cloud.
	public static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: CodableCoreDataManageable?
	) -> [CKRecord] {
		let elements: [Self] = Self.getAll(with: manager) { fetchRequest in
			if !isFullDatabaseCopy {
				fetchRequest.predicate = NSPredicate(format: "(isSavedToCloud == false)")
			}
		}
		elements.forEach { defaultManager.log("\(type(of: $0)) \($0.getIdentifyingName())") }
		return elements.map { $0.createSaveRecord() }
	}
}

extension CloudDataStorable where Self: GameRowStorable {

    /// (CloudDataStorable x CodableCoreDataStorable Protocol)
    /// Get all objects to be saved to cloud.
    public static func getAllSavesToCloud(
        isFullDatabaseCopy: Bool,
        with manager: CodableCoreDataManageable?
    ) -> [CKRecord] {
        let elements: [Self] = Self.getAllExisting(with: manager) { fetchRequest in
            if !isFullDatabaseCopy {
                fetchRequest.predicate = NSPredicate(format: "(isSavedToCloud == false)")
            }
        }
        elements.forEach { defaultManager.log("\(type(of: $0)) \($0.getIdentifyingName())") }
        return elements.map { $0.createSaveRecord() }
    }

    /// (CloudDataStorable x GameRowStorable Protocol)
    /// Create a recordName for any cloud kit object.
    public static func getIdentifyingName(
        id: String,
        gameSequenceUuid: UUID?
    ) -> String {
        return "\(gameSequenceUuid?.uuidString ?? "")||\(id)"
    }

    /// Convenience version - get the static getIdentifyingName for easy instance reference.
    public func getIdentifyingName() -> String {
        return Self.getIdentifyingName(id: id, gameSequenceUuid: gameSequenceUuid)
    }

    /// (CloudDataStorable x GameRowStorable Protocol)
    /// Parses a cloud identifier into the parts needed to retrieve it from core data.
    public static func parseIdentifyingName(
        name: String
    ) -> ((id: String, gameSequenceUuid: UUID)?) {
        let pieces = name.components(separatedBy: "||")
        guard pieces.count == 2 else { return nil }
        if let gameSequenceUuid = UUID(uuidString: pieces[0]) {
            return (id: pieces[1], gameSequenceUuid: gameSequenceUuid)
        } else {
            defaultManager.log("No Game UUID found for: \(name)")
            return nil
        }
    }

    /// (CloudDataStorable x GameRowStorable Protocol)
    /// Get all the values matching the list of cloud identifiers.
    public static func getAll(
        identifiers: [String],
        with manager: CodableCoreDataManageable?
    ) -> [Self] {
        return identifiers.reduce([]) { (list: [Self], identifier: String) -> [Self] in
            if let (id, uuid) = parseIdentifyingName(name: identifier),
                let found = getExisting(id: id, gameSequenceUuid: uuid, with: manager) {
                return list + [found]
            }
            return list
        }
    }

    /// (CloudDataStorable x GameRowStorable Protocol)
    /// Set identifying fields for a cloud kit object.
    public func setIdentifyingCloudFields(record: CKRecord) {
        record.setValue(
            id as NSString,
            forKey: "id"
        )
        record.setValue(
            (gameSequenceUuid?.uuidString ?? "") as NSString,
            forKey: "gameSequenceUuid"
        )
    }

    /// (CloudDataStorable x GameRowStorable Protocol)
    /// Takes one serialized cloud change and saves it.
    public static func saveOneFromCloud(
        changeRecord: CloudDataRecordChange,
        with manager: CodableCoreDataManageable?
    ) -> Bool {
        let recordId = changeRecord.recordId
        if let (id, uuid) = parseIdentifyingName(name: recordId),
            var element = Self.getExisting(id: id, gameSequenceUuid: uuid, with: manager)
                            ?? Self.get(id: id, with: manager) {
            // apply cloud changes
            element.gameSequenceUuid = uuid
            element.rawData = nil
            let changes = element.getAdditionalCloudFields(changeRecord: changeRecord)
            element = element.changed(changes)
            // special case
            if element.pendingCloudChanges["photo"] == nil, // don't overwrite pending
                var photographicalElement = element as? PhotoEditable,
                let image = GamesDataBackup.current.getCachedImage(recordId: recordId, key: "photoFile") {
                _ = photographicalElement.savePhoto(image: image, isSave: false)
            }
            element.isSavedToCloud = true
            // reapply any local changes
            if !element.pendingCloudChanges.isEmpty {
                element = element.changed(element.pendingCloudChanges.dictionary)
                element.isSavedToCloud = false
            }
            // save locally
            if element.save(with: manager) {
                print("Saved from cloud \(recordId)")
                return true
            } else {
                print("Save from cloud failed \(recordId)")
            }
        }
        return false
    }

    /// (Protocol default)
    /// Delete a local object after directed by the cloud to do so.
    public static func deleteOneFromCloud(
        recordId: String
    ) -> Bool {
        guard let (id, uuid) = parseIdentifyingName(name: recordId) else { return false }
        return delete(id: id, gameSequenceUuid: uuid)
    }

}

extension CloudDataStorable where Self: DateModifiable {
	/// (Protocol default)
	/// Set date fields for a cloud kit object.
	public func setDateModifiableCloudFields(record: CKRecord) {
		record.setValue(createdDate as NSDate, forKey: "createdDate")
		record.setValue(modifiedDate as NSDate, forKey: "modifiedDate")
	}
}

// MARK: Serializable Utilities
extension CloudDataStorable {
    public mutating func unserializeLocalCloudData(_ data: [String: Any?]) {
        isSavedToCloud = (data["isSavedToCloud"] as? Bool) ?? isSavedToCloud
        lastRecordData = (data["lastRecordData"] as? Data) ?? lastRecordData
        pendingCloudChanges = (data["pendingCloudChanges"] as? CodableDictionary)
            ?? pendingCloudChanges
    }
}
extension CloudDataStorable where Self: Codable {
    /// Fetch Cloud Data from a Codable dictionary.
    public mutating func unserializeLocalCloudData(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CloudDataStorableCodingKeys.self)
        isSavedToCloud = try container.decodeIfPresent(Bool.self, forKey: .isSavedToCloud) ?? isSavedToCloud
        lastRecordData = try container.decodeIfPresent(Data.self, forKey: .lastRecordData) ?? lastRecordData
        pendingCloudChanges = try container.decodeIfPresent(
            CodableDictionary.self,
            forKey: .pendingCloudChanges
        ) ?? pendingCloudChanges
    }
    /// Store Cloud Data value to a Codable dictionary.
    public func serializeLocalCloudData(encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CloudDataStorableCodingKeys.self)
        try container.encode(isSavedToCloud, forKey: .isSavedToCloud)
        try container.encode(lastRecordData, forKey: .lastRecordData)
        try container.encode(pendingCloudChanges, forKey: .pendingCloudChanges)
    }
}

/// Codable keys for objects adhering to DateModifiable
public enum CloudDataStorableCodingKeys: String, CodingKey {
    case isSavedToCloud
    case lastRecordData
    case pendingCloudChanges
}

// swiftlint:enable file_length
