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
	/// (Default provided for SimpleSerializedCoreDataStorable objects.)
	static var cloudRecordType: String { get }

	/// Core data identifying entity name.
	static var entityName: String { get }

	/// Flag for whether the local object has changes not saved to the cloud.
	/// This value is used for gathering local objects from the core data store.
	var isSavedToCloud: Bool { get set }

	/// A set of any changes to the local object since the last cloud sync.
	var pendingCloudChanges: SerializableData? { get set }

	/// A copy of the last cloud kit record.
	var lastRecordData: Data? { get set }

	/// Create a recordName for any cloud kit object.
	func getIdentifyingName() -> String

	/// Set any additional fields, specific to the object in question, for a cloud kit object.
	func setAdditionalCloudFields(record: CKRecord)

	/// Set identifying fields for a cloud kit object. 
	/// (Default provided for GameRowStorable objects.)
	func setIdentifyingCloudFields(record: CKRecord)

	/// Set date fields for a cloud kit object. 
	/// (Default provided for DateModifiable objects.)
	func setDateModifiableCloudFields(record: CKRecord)

	/// Get all objects to be saved to cloud. 
	/// (Default provided for SimpleSerializedCoreDataStorable objects.)
	static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: SimpleSerializedCoreDataManageable?
	) -> [CKRecord]

	/// Delete a local object after directed by the cloud to do so. 
	/// (Default provided for GameRowStorable objects.)
	static func deleteOneFromCloud(recordId: String) -> Bool

// MARK: Optional

	/// A reference to the current cloud kit manager.
	static var defaultManager: SimpleCloudKitManageableConforming { get set }

	/// Create a consistent record id for any cloud kit object.
	func getRecordId() -> CKRecordID

	/// Create a consistent record id based on a provided recordName.
	static func getRecordId(
		recordName: String
	) -> CKRecordID

	/// Save changed fields and mark local object as needing a cloud sync.
	mutating func notifySaveToCloud(fields: [String: SerializedDataStorable?])

	/// Create a CKRecord and set all the fields to current values.
	func createSaveRecord() -> CKRecord

	/// Create a CKRecord object (based on object's last record object, if it is available).
	func createCKRecord() -> CKRecord

	/// Set relevant fields for a cloud kit object - DO NOT OVERRIDE.
	func setCloudFields(record: CKRecord)

	/// Any action on completion of a cloud save.
	static func confirmRecordSaved(
		record: CKRecord,
		with manager: SimpleSerializedCoreDataManageable?
	)

	/// Create a delete object and flag local manager that we need a cloud sync.
	mutating func notifyDeleteToCloud()

	/// Get all objects to be deleted in cloud.
	static func getAllDeletesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: SimpleSerializedCoreDataManageable?
	) -> [CKRecordID]

	/// Any action on completion of a cloud delete.
	static func confirmRecordIdDeleted(
		recordId: CKRecordID,
		with manager: SimpleSerializedCoreDataManageable?
	)

	/// Takes a gathered set of serialized cloud changes and batch saves them.
	static func saveAllFromCloud(
		changes: [SerializableData],
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Takes one serialized cloud change and saves it.
	static func saveOneFromCloud(
		changeSet: SerializableData,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Translate a record object into a local serialized value for local batch save.
	static func serializeRecordSave(
		record: CKRecord
	) -> SerializableData

	/// Translate a record object into a local serialized value for local batch delete.
	static func serializeRecordDelete(
		recordId: CKRecordID
	) -> SerializableData
}

// default implementations for the protocol:
extension CloudDataStorable {

// MARK: Get

	/// (Protocol default)
	/// Create a consistent record id for any cloud kit object.
	public func getRecordId() -> CKRecordID {
		return CKRecordID(recordName: getIdentifyingName(), zoneID: GamesDataBackup.current.zoneId)
	}

	/// (Protocol default)
	/// Create a consistent record id based on a provided recordName.
	public static func getRecordId(
		recordName: String
	) -> CKRecordID {
		return CKRecordID(recordName: recordName, zoneID: GamesDataBackup.current.zoneId)
	}

// MARK: Save

	/// (Protocol default)
	/// Save changed fields and mark local object as needing a cloud sync.
	public mutating func notifySaveToCloud(
		fields: [String: SerializedDataStorable?]
	) {
		var pendingCloudChanges = self.pendingCloudChanges ?? SerializableData()
		for (key, value) in fields {
			pendingCloudChanges[key] = value?.getData() ?? nil
		}

//		if let datedSelf = self as? DateModifiable {
//			pendingCloudChanges["modifiedDate"] = datedSelf.modifiedDate.getData()
//		}
		self.pendingCloudChanges = pendingCloudChanges
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
		if let archivedData = lastRecordData {
			let unarchiver = NSKeyedUnarchiver(forReadingWith: archivedData)
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
		with manager: SimpleSerializedCoreDataManageable?
	) {}

	/// (Protocol default)
	/// Takes a gathered set of serialized cloud changes and batch saves them.
	public static func saveAllFromCloud(
		changes: [SerializableData],
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		guard !changes.isEmpty else { return true }
		var isSaved = true
		for changeSet in changes {
			if let recordId = changeSet["recordId"]?.string, changeSet["isDelete"]?.bool == true {
				if Self.deleteOneFromCloud(recordId: recordId) {
					print("Delete from cloud \(recordId)")
				} else {
					isSaved = false
					print("Delete from cloud failed \(recordId)")
				}
				continue
			}
			isSaved = saveOneFromCloud(changeSet: changeSet, with: manager)
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
		with manager: SimpleSerializedCoreDataManageable?
	) -> [CKRecordID] {
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
		recordId: CKRecordID,
		with manager: SimpleSerializedCoreDataManageable?
	) {
		_ = DeletedRow.delete(identifier: recordId.recordName, with: manager)
	}

// MARK: Serialize Records

	/// (Protocol default)
	/// Translate a record object into a local serialized value for local batch save.
	public static func serializeRecordSave(
		record: CKRecord
	) -> SerializableData {
		var existingData = SerializableData()
		existingData["recordId"] = record.recordID.recordName.getData()
		for key in record.allKeys() {
			if record[key] is NSNumber {
				existingData[key] = (record[key] as? Double)?.getData()
			} else if record[key] is NSString {
				existingData[key] = (record[key] as? String)?.getData()
			} else if record[key] is NSDate {
				existingData[key] = (record[key] as? Date)?.getData()
			} else if record[key] is NSArray {
				if let value = (record[key] as? NSArray) as? [String] {
					existingData[key] = try? SerializableData(value)
				} else {
					existingData[key] = nil
				}
			} else if record[key] is CKAsset {
				if let imageUrl = record[key] as? CKAsset,
					let image = UIImage(contentsOfFile: imageUrl.fileURL.path) {
					GamesDataBackup.current.cacheImage(image, recordId: record.recordID.recordName, key: key)
				}
			} else {
				existingData[key] = nil
			}
		}
		existingData["changedKeys"] = try? SerializableData(record.changedKeys())
		existingData["lastRecordData"] = serializeLastRecordData(record: record)
		return existingData
	}

	/// (Protocol default)
	/// Translate a record object into a local serialized value for local batch delete.
	public static func serializeRecordDelete(
		recordId: CKRecordID
	) -> SerializableData {
		var existingData = SerializableData()
		existingData["recordId"] = recordId.recordName.getData()
		existingData["isDelete"] = true.getData()
		return existingData
	}

	/// Translate a record object into a local serialized value, to be stored for later use.
	internal static func serializeLastRecordData(
		record: CKRecord
	) -> SerializableData {
		let archivedData = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWith: archivedData)
		archiver.requiresSecureCoding = true
		record.encodeSystemFields(with: archiver)
		archiver.finishEncoding()
		return (archivedData as Data).getData()
	}

}

// MARK: Extensions - Self: {Protocol}

// (Note: these protocols can't use Self or associatedType)
extension CloudDataStorable where Self: SimpleSerializedCoreDataStorable {

	/// (CloudDataStorable x SimpleSerializedCoreDataStorable Protocol)
	/// The cloudkit entity name for this object.
	public static var cloudRecordType: String { return entityName }

	/// (CloudDataStorable x SimpleSerializedCoreDataStorable Protocol)
	/// Get all objects to be saved to cloud.
	public static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: SimpleSerializedCoreDataManageable?
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

	/// (CloudDataStorable x SimpleSerializedCoreDataStorable Protocol)
	/// Get all objects to be saved to cloud.
	public static func getAllSavesToCloud(
		isFullDatabaseCopy: Bool,
		with manager: SimpleSerializedCoreDataManageable?
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
		gameSequenceUuid: String?
	) -> String {
		return "\(gameSequenceUuid ?? "")||\(id)"
	}

	/// Convenience version - get the static getIdentifyingName for easy instance reference.
	public func getIdentifyingName() -> String {
		return Self.getIdentifyingName(id: id, gameSequenceUuid: gameSequenceUuid)
	}

	/// (CloudDataStorable x GameRowStorable Protocol)
	/// Parses a cloud identifier into the parts needed to retrieve it from core data.
	public static func parseIdentifyingName(
		name: String
	) -> ((id: String, gameSequenceUuid: String)?) {
		let pieces = name.components(separatedBy: "||")
		guard pieces.count == 2 else { return nil }
		return (id: pieces[1], gameSequenceUuid: pieces[0])
	}

	/// (CloudDataStorable x GameRowStorable Protocol)
	/// Get all the values matching the list of cloud identifiers.
	public static func getAll(
		identifiers: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self] {
		return identifiers.flatMap { (identifier: String) in
			if let (id, uuid) = parseIdentifyingName(name: identifier) {
				return getExisting(id: id, gameSequenceUuid: uuid, with: manager)
			}
			return nil
		}
	}

	/// (CloudDataStorable x GameRowStorable Protocol)
	/// Set identifying fields for a cloud kit object.
	public func setIdentifyingCloudFields(record: CKRecord) {
		record.setValue(id as NSString, forKey: "id")
		record.setValue((gameSequenceUuid ?? "") as NSString, forKey: "gameSequenceUuid")
	}

	/// (CloudDataStorable x GameRowStorable Protocol)
	/// Takes one serialized cloud change and saves it.
	public static func saveOneFromCloud(
		changeSet: SerializableData,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		if let recordId = changeSet["recordId"]?.string,
			let (id, uuid) = parseIdentifyingName(name: recordId),
			var element = Self.getExisting(id: id, gameSequenceUuid: uuid, with: manager)
							?? Self.get(id: id, with: manager) {
			let pendingData = element.pendingCloudChanges
			// apply cloud changes
			element.setData(changeSet)
			element.gameSequenceUuid = uuid
			element.isSavedToCloud = true
			// reapply local changes
			if let pendingData = pendingData {
				element.setData(pendingData)
				element.isSavedToCloud = false
				// re-store pending changes until object is saved to cloud
				element.pendingCloudChanges = pendingData
			}
			element.isSavedToCloud = true
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
extension CloudDataStorable where Self: SerializedDataStorable, Self: SerializedDataRetrievable {

	/// Save CloudDataStorable values to a SerializedData dictionary.
	public func serializeLocalCloudData(
		list: [String: SerializedDataStorable?]
	) -> [String: SerializedDataStorable?] {
		var list = list
		list["isSavedToCloud"] = isSavedToCloud
		list["pendingCloudChanges"] = pendingCloudChanges
		list["lastRecordData"] = lastRecordData
		return list
	}

	/// Retrieve CloudDataStorable values from a SerializedData dictionary.
	public mutating func unserializeLocalCloudData(
		data: SerializableData
	) {
		isSavedToCloud = data["isSavedToCloud"]?.bool ?? isSavedToCloud
		pendingCloudChanges = data["pendingCloudChanges"]
		lastRecordData = data["lastRecordData"]?.data
	}
}
// swiftlint:enable file_length
