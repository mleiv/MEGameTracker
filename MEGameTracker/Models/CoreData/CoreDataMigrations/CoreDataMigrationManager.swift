//
//  CoreDataMigrationManager.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/1/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

// Not asynchronous. All actions may depend on prior actions.
public struct CoreDataMigrationManager {
	// Transient value: we just don't want to load same data twice during same app load.
	// We *will* want to load base data multiple times, if data has changed between builds.
	public static var didLoadBaseData = false

	public let migrationsAvailable: [CoreDataMigration] = [ // Int is just for easier reference when editing
		CoreDataMigration(fromBuild: 73, loadMigration: { return BaseDataImport() }),
//        CoreDataMigration(fromBuild: 54, loadMigration: { return CoreDataEliminateDuplicates() }),
		CoreDataMigration(fromBuild: 42, loadMigration: { return Change20170228() }),
		CoreDataMigration(fromBuild: 44, loadMigration: { return Change20170305() }),
        CoreDataMigration(fromBuild: 47, loadMigration: { return Change20170905() }),
        CoreDataMigration(fromBuild: 48, loadMigration: { return Change20171022() }),
        CoreDataMigration(fromBuild: 56, loadMigration: { return Change20180203() }),
        CoreDataMigration(fromBuild: 60, loadMigration: { return EventTriggerMigration() }),
        CoreDataMigration(fromBuild: 62, loadMigration: { return Change20190527() }),
        CoreDataMigration(fromBuild: 65, loadMigration: { return MapIsExploredMigration() }),
        CoreDataMigration(fromBuild: 67, loadMigration: { return EventGameVersionMigration() }),
	]

	public func migrateFrom(lastBuild: Int, completion: @escaping (() -> Void) = {}) {
		// reload base data on every new build
		if lastBuild < App.current.build {
			CoreDataMigrations.isRunning = true
			CoreDataMigrations.onStart.fire(true)
		}

//        let lastBuild = 55 // DEBUG
		for (migration) in migrationsAvailable {
			if migration.fromBuild > lastBuild && migration.fromBuild <= App.current.build {
				CoreDataMigrations.isRunning = true
				migration.loadMigration().run()
			}
		}
		App.current.lastBuild = App.current.build
		if CoreDataMigrations.isRunning {
			CoreDataMigrations.isRunning = false
			CoreDataMigrations.onFinish.fire(true)
		}

		DispatchQueue.main.async {
			completion()
		}
	}

//	private func deleteRowsMissingGame() {
//		
//		// temp fix for data corruption while testing
//		let gameIds = GameSequence.getAllIds()
//		var deletedRows: [DeletedRow] = []
//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Decision.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//				format: "!(%K in %@)",
//				#keyPath(GameDecisions.gameSequenceUuid),
//				gameIds
//			)
//		}.map {
//			_ = Decision.delete(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Decision.entityName,
//				identifier: Decision.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Event.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//					format: "!(%K in %@)",
//				#keyPath(GameEvents.gameSequenceUuid),
//				gameIds
//			)
//		}.map {
//			_ = Event.delete(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Event.entityName,
//				identifier: Event.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Item.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//				format: "!(%K in %@)",
//				#keyPath(GameItems.gameSequenceUuid),
//				gameIds
//			)
//		}.map {
//			_ = Item.delete(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Item.entityName,
//				identifier: Item.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Map.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//				format: "!(%K in %@)",
//				#keyPath(GameMaps.gameSequenceUuid),
//				gameIds
//			)
//		}.map {
//			_ = Map.delete(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Map.entityName,
//				identifier: Map.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Mission.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//				format: "!(%K in %@)",
//				#keyPath(GameMissions.gameSequenceUuid),
//				gameIds
//			)
//		}.map {
//			_ = Mission.delete(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Mission.entityName,
//				identifier: Mission.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Note.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//					format: "!(%K in %@)",
//					#keyPath(GameNotes.gameSequenceUuid),
//					gameIds
//				)
//		}.map {
//			_ = Note.delete(uuid: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Note.entityName,
//				identifier: Note.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		deletedRows += GameSequence.getAllIdentifiers(ofType: Shepard.self) { fetchRequest in
//			fetchRequest.predicate = NSPredicate(
//					format: "!(%K in %@)",
//					#keyPath(GameShepards.gameSequenceUuid),
//					gameIds
//				)
//		}.map {
//			_ = Shepard.delete(uuid: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			return DeletedRow(
//				source: Shepard.entityName,
//				identifier: Shepard.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
//			)
//		}

//		
//		_ = DeletedRow.saveAll(items: deletedRows)
//		GamesDataBackup.current.isPendingCloudChanges = true
//	}
}
