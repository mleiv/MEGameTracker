//
//  GamesDataBackup.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit
import CloudKit

final public class GamesDataBackup: SimpleCloudKitManageable {
	public static var current: SimpleCloudKitManageable = GamesDataBackup()
	// MARK: customizable
	public var isLog: Bool = true
	public var postChangeWaitIntervalSeconds: TimeInterval = 60.0 * 5.0 // 5 minute save interval
	public var subscriptionId: String = "GameData"
	public var zoneName: String = "GameData"
	public var containerId: String? { return container.containerIdentifier }
	// public let containerId = "com.urdnot.megametracker"
	public lazy var container = CKContainer.default()//{ return CKContainer(identifier: containerId) }()
	public func saveOneFromCloud(
		record: CKRecord,
		completion: @escaping ((Bool) -> Void)
	) {
		log("saveOneFromCloud recordType = \(record.recordType) record = \(record.recordID.recordName)")
		let isQueued = queueSaveFromCloud(record: record)
		completion(isQueued)
	}
	public func deleteOneFromCloud(
		recordId: CKRecordID,
		recordType: String,
		completion: @escaping ((Bool) -> Void)
	) {
		log("deleteOneFromCloud recordType = \(recordType) record = \(recordId.recordName)")
		let isQueued = queueDeleteFromCloud(recordId: recordId, recordType: recordType)
		completion(isQueued)
	}
	public func changesFromCloudCompletion(
		isSuccess: Bool,
		completion: @escaping ((Bool) -> Void)
	) {
		log("changesFromCloudCompletion isSuccess = \(isSuccess)")
		let isSaved = isSuccess && saveAllChangesFromCloud()
		completion(isSaved)
	}
	public func fetchSavesToCloud() -> [CKRecord] {
		return gatherAllSavesToCloud()
	}
	public func fetchDeletesToCloud() -> [CKRecordID] {
		return gatherAllDeletesToCloud()
	}
	public func changesToCloudCompletion(
		isSuccess: Bool,
		savedRecords: [CKRecord],
		deletedRecordIds: [CKRecordID],
		completion: @escaping ((Bool) -> Void)
	) {
		log("changesToCloudCompletion isSuccess = \(isSuccess) " +
			"savedRecords = \(savedRecords.count) deletedRecordIds = \(deletedRecordIds)")
		// it's okay to process the incoming data even if something failed (these are only the successes).
		let isSaved = confirmAllChangesToCloud(savedRecords: savedRecords, deletedRecordIds: deletedRecordIds)
		completion(isSaved && isSuccess)
	}
	public func resetLocalData(completion: @escaping ((Bool) -> Void)) {
		log("resetLocalData")
		let isSaved = deleteAllGameData()
		completion(isSaved)
	}
	// MARK: transitory stored data
	public var isPendingCloudChanges: Bool = false
	public var qualityOfService: QualityOfService?
	public var appState: AppStateForCloud = .start
	public var isSyncing: Bool = false
	public var isFetchingChanges: Bool = false
	public var isPostingChanges: Bool = false
	public var isSubscribed: Bool = false
	public var isAccountChangeSubscribed: Bool = false
	public var isZoneInitialized: Bool = false
	public var isAvailabilityChecked: Bool = false
	public var accountStatus: CKAccountStatus = .noAccount
	public var lastPostedDate: Date = Date.distantPast
	public var cachedCloudImages: [String: UIImage] = [:]
	// MARK: permanent stored data
	public var isUseCloud: Bool {
		get { return internalIsUseCloud.get() ?? true }
		set { return internalIsUseCloud.set(newValue) }
	}
	public var isFirstSync: Bool {
		get { return internalIsFirstSync.get() ?? false }
		set { return internalIsFirstSync.set(newValue) }
	}
	public var isCloudQuotaExceeded: Bool {
		get { return internalIsCloudQuotaExceeded.get() ?? false }
		set { return internalIsCloudQuotaExceeded.set(newValue) }
	}
	public var accountName: String? {
		get { return internalAccountName.get() }
		set { return internalAccountName.set(newValue) }
	}
	public var changeToken: CKServerChangeToken? {
		get { return internalChangeToken.get() }
		set { return internalChangeToken.set(newValue) }
	}

	// Specific to GameDataBackup

	var internalIsUseCloud = SimpleUserDefaults<Bool>(name: "IsUseGameDataCloud", defaultValue: true)
	var internalIsFirstSync = SimpleUserDefaults<Bool>(name: "IsFirstGameDataSync", defaultValue: true)
	var internalIsCloudQuotaExceeded = SimpleUserDefaults<Bool>(name: "IsCloudQuotaExceeded", defaultValue: false)
	var internalAccountName = SimpleUserDefaults<String>(name: "GameDataAccountName")
	var internalChangeToken = SimpleUserDefaults<CKServerChangeToken>(name: "GameDataChangeToken")

	var decisionChanges: [SerializableData] = []
	var eventChanges: [SerializableData] = []
	var itemChanges: [SerializableData] = []
	var mapChanges: [SerializableData] = []
	var missionChanges: [SerializableData] = []
	var noteChanges: [SerializableData] = []
	var personChanges: [SerializableData] = []
	var gameChanges: [SerializableData] = []
	var shepardChanges: [SerializableData] = []

	public func queueSaveFromCloud(record: CKRecord) -> Bool {
		log("queueSaveFromCloud \(record.recordType)")
		switch record.recordType {
			case Decision.entityName:
				decisionChanges.append(Decision.serializeRecordSave(record: record))
			case Event.entityName:
				eventChanges.append(Event.serializeRecordSave(record: record))
			case Item.entityName:
				itemChanges.append(Item.serializeRecordSave(record: record))
			case Map.entityName:
				mapChanges.append(Map.serializeRecordSave(record: record))
			case Mission.entityName:
				missionChanges.append(Mission.serializeRecordSave(record: record))
			case Note.entityName:
				noteChanges.append(Note.serializeRecordSave(record: record))
			case Person.entityName:
				personChanges.append(Person.serializeRecordSave(record: record))
			case GameSequence.entityName:
				gameChanges.append(GameSequence.serializeRecordSave(record: record))
			case Shepard.entityName:
				shepardChanges.append(Shepard.serializeRecordSave(record: record))
			default: return false
		}
		return true
	}

	public func queueDeleteFromCloud(recordId: CKRecordID, recordType: String) -> Bool {
		log("queueDeleteFromCloud \(recordType)")
		switch recordType {
			case Decision.entityName:
				decisionChanges.append(Decision.serializeRecordDelete(recordId: recordId))
			case Event.entityName:
				eventChanges.append(Event.serializeRecordDelete(recordId: recordId))
			case Item.entityName:
				itemChanges.append(Item.serializeRecordDelete(recordId: recordId))
			case Map.entityName:
				mapChanges.append(Map.serializeRecordDelete(recordId: recordId))
			case Mission.entityName:
				missionChanges.append(Mission.serializeRecordDelete(recordId: recordId))
			case Note.entityName:
				noteChanges.append(Note.serializeRecordDelete(recordId: recordId))
			case Person.entityName:
				personChanges.append(Person.serializeRecordDelete(recordId: recordId))
			case GameSequence.entityName:
				gameChanges.append(GameSequence.serializeRecordDelete(recordId: recordId))
			case Shepard.entityName:
				shepardChanges.append(Shepard.serializeRecordDelete(recordId: recordId))
			default: return false
		}
		return true
	}

	public func saveAllChangesFromCloud() -> Bool {
		log("saveAllChangesFromCloud gameChanges = \(gameChanges.count) " +
			"shepardChanges = \(shepardChanges.count) mapChanges = \(mapChanges.count) " +
			"missionChanges = \(missionChanges.count) personChanges = \(personChanges.count) " +
			"decisionChanges = \(decisionChanges.count) itemChanges = \(itemChanges.count) " +
			"noteChanges = \(noteChanges.count) eventChanges = \(eventChanges.count)")
		let manager = CoreDataManager.current

		var isSaved = true

		isSaved = isSaved && GameSequence.saveAllFromCloud(changes: gameChanges, with: manager)
		isSaved = isSaved && Shepard.saveAllFromCloud(changes: shepardChanges, with: manager)
		isSaved = isSaved && Map.saveAllFromCloud(changes: mapChanges, with: manager)
		isSaved = isSaved && Mission.saveAllFromCloud(changes: missionChanges, with: manager)
		isSaved = isSaved && Person.saveAllFromCloud(changes: personChanges, with: manager)
		isSaved = isSaved && Decision.saveAllFromCloud(changes: decisionChanges, with: manager)
		isSaved = isSaved && Item.saveAllFromCloud(changes: itemChanges, with: manager)
		isSaved = isSaved && Note.saveAllFromCloud(changes: noteChanges, with: manager)
		isSaved = isSaved && Event.saveAllFromCloud(changes: eventChanges, with: manager)

		decisionChanges = []
		eventChanges = []
		itemChanges = []
		mapChanges = []
		missionChanges = []
		noteChanges = []
		personChanges = []
		gameChanges = []
		shepardChanges = []

		return isSaved
	}

	public func gatherAllSavesToCloud() -> [CKRecord] {
		let manager = CoreDataManager.current
		let isFullDatabaseCopy: Bool = isFirstSync
		var records: [CKRecord] = []

		records += Decision.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Event.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Item.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Map.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Mission.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Note.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Person.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += GameSequence.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)
		records += Shepard.getAllSavesToCloud(isFullDatabaseCopy: isFullDatabaseCopy, with: manager)

		log("gatherAllSavesToCloud records = \(records.count)")

		return records
	}

	public func gatherAllDeletesToCloud() -> [CKRecordID] {
		guard !isFirstSync else { return [] }
		let manager = CoreDataManager.current
		var recordIds: [CKRecordID] = []

		recordIds += DeletedRow.getAllDeletesToCloud(isFullDatabaseCopy: false, with: manager)

		log("gatherAllDeletesToCloud records = \(recordIds.count)")

		return recordIds
	}

	public func confirmAllChangesToCloud (
		savedRecords: [CKRecord],
		deletedRecordIds: [CKRecordID]
	) -> Bool {
		if isFirstSync && accountStatus != .available {
			return deleteAllPendingCloudData()
		}

		let manager = CoreDataManager.current

		// There is a small risk that we will delete changes made between the time of the post and the response. 
		// I am not dealing with that yet.
		// There is larger risk another copy of object currently open will re-save pending changes back to core data.
		// Which will just result in it being saved twice, not a hugely dangerous thing.

		let isConfirmed = true // we really don't need to halt anything if this breaks - it will just resend later.

		let decisionIdentifiers = savedRecords.filter {
			$0.recordType == Decision.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Decision.getAll(identifiers: decisionIdentifiers, with: manager).forEach {
			var d = $0; d.pendingCloudChanges = nil; _ = d.save(with: manager)
		}
		let eventIdentifiers = savedRecords.filter {
			$0.recordType == Event.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Event.getAll(identifiers: eventIdentifiers, with: manager).forEach {
			var e = $0; e.pendingCloudChanges = nil; _ = e.save(with: manager)
		}
		let itemIdentifiers = savedRecords.filter {
			$0.recordType == Item.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Item.getAll(identifiers: itemIdentifiers, with: manager).forEach {
			var i = $0; i.pendingCloudChanges = nil; _ = i.save(with: manager)
		}
		let mapIdentifiers = savedRecords.filter {
			$0.recordType == Map.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Map.getAll(identifiers: mapIdentifiers, with: manager).forEach {
			var m = $0; m.pendingCloudChanges = nil; _ = m.save(with: manager)
		}
		let missionIdentifiers = savedRecords.filter {
			$0.recordType == Mission.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Mission.getAll(identifiers: missionIdentifiers, with: manager).forEach {
			var m = $0; m.pendingCloudChanges = nil; _ = m.save(with: manager)
		}
		let noteIdentifiers = savedRecords.filter {
			$0.recordType == Note.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Note.getAll(identifiers: noteIdentifiers, with: manager).forEach {
			var n = $0; n.pendingCloudChanges = nil; _ = n.save(with: manager)
		}
		let personIdentifiers = savedRecords.filter {
			$0.recordType == Person.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Person.getAll(identifiers: personIdentifiers, with: manager).forEach {
			var p = $0; p.pendingCloudChanges = nil; _ = p.save(with: manager)
		}
		let gameIdentifiers = savedRecords.filter {
			$0.recordType == GameSequence.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		GameSequence.getAll(identifiers: gameIdentifiers, with: manager).forEach {
			var g = $0; g.pendingCloudChanges = nil; _ = g.save(with: manager)
		}
		let shepardIdentifiers = savedRecords.filter {
			$0.recordType == Shepard.cloudRecordType
		}.flatMap { $0.recordID.recordName }
		Shepard.getAll(identifiers: shepardIdentifiers, with: manager).forEach {
			var s = $0; s.pendingCloudChanges = nil; _ = s.save(with: manager)
		}

		log("confirmAllChangesToCloud decisionIdentifiers = \(decisionIdentifiers.count) " +
			"eventIdentifiers = \(eventIdentifiers.count) itemIdentifiers = \(itemIdentifiers.count) " +
			"mapIdentifiers = \(mapIdentifiers.count) missionIdentifiers = \(missionIdentifiers.count) " +
			"noteIdentifiers = \(noteIdentifiers.count) personIdentifiers = \(personIdentifiers.count) " +
			"gameIdentifiers = \(gameIdentifiers.count) shepardIdentifiers = \(shepardIdentifiers.count) " +
			"deletedRecordIds = \(deletedRecordIds.count)")

		_ = DeletedRow.deleteAll(identifiers: deletedRecordIds.map { $0.recordName }, with: manager)

		return isConfirmed
	}

	/// A reset for game data.
	public func deleteAllGameData() -> Bool {
		log("deleteAllGameData")

		var isDeleted = true
		let manager = CoreDataManager.current

		isDeleted = isDeleted && Decision.deleteAll(with: manager)
		isDeleted = isDeleted && Event.deleteAll(with: manager)
		isDeleted = isDeleted && Item.deleteAll(with: manager)
		isDeleted = isDeleted && Map.deleteAll(with: manager)
		isDeleted = isDeleted && Mission.deleteAll(with: manager)
		isDeleted = isDeleted && Note.deleteAll(with: manager)
		isDeleted = isDeleted && Person.deleteAll(with: manager)
		isDeleted = isDeleted && GameSequence.deleteAll(with: manager)
		isDeleted = isDeleted && Shepard.deleteAll(with: manager)

		return isDeleted
	}

	/// A reset for game data.
	public func deleteAllPendingCloudData() -> Bool {
		log("deleteAllPendingCloudData")
		// we are ignoring the extra pendingData for now. It isn't THAT much extra overhead

		let manager = CoreDataManager.current

		return DeletedRow.deleteAll(with: manager)
	}
}

extension CloudDataStorable {
	/// A reference to the current cloud kit manager.
	public static var defaultManager: SimpleCloudKitManageableConforming {
		get { return GamesDataBackup.current }
		set { GamesDataBackup.current = (newValue as? GamesDataBackup) ?? GamesDataBackup.current }
	}
}
