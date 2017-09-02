//
//  BaseDataImport.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/1/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct BaseDataImport: CoreDataMigrationType {

	let progressProcessImportChunk = 40.0
	let progressFinalPadding = 5.0
	let onProcessMapDataRow = Signal<Bool>()
	let onProcessMissionDataRow = Signal<Bool>()

	var isTestProject: Bool {
		return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
	}

	let manager: CodableCoreDataManageable?

	public init(manager: CodableCoreDataManageable? = nil) {
		self.manager = manager ?? CoreDataManager.current
	}

	public func run() {
		// Don't run base data load twice on same data:
		guard !CoreDataMigrationManager.didLoadBaseData else { return }
		addData()
		CoreDataMigrationManager.didLoadBaseData = true
		print("Installed base data")
	}

	// Must group these by type
	public typealias CoreDataFileImport = (type: BaseDataFileImportType, filename: String, progress: Double)

	public let progressFiles: [CoreDataFileImport] = [
		(type: .event, filename: "DataEvents_1", progress: 1),
		(type: .event, filename: "DataEvents_2", progress: 1),
		(type: .event, filename: "DataEvents_3", progress: 1),
		(type: .decision, filename: "DataDecisions_1", progress: 1),
		(type: .decision, filename: "DataDecisions_2", progress: 1),
		(type: .decision, filename: "DataDecisions_3", progress: 1),
		(type: .person, filename: "DataPersons_1", progress: 1),
		(type: .person, filename: "DataPersons_1Others", progress: 3),
		(type: .person, filename: "DataPersons_2", progress: 1),
		(type: .person, filename: "DataPersons_2Others", progress: 3),
		(type: .person, filename: "DataPersons_3", progress: 1),
		(type: .person, filename: "DataPersons_3Others", progress: 3),
		(type: .map, filename: "DataMaps_Primary", progress: 2),
		(type: .map, filename: "DataMaps_TerminusSystems", progress: 5),
		(type: .map, filename: "DataMaps_AtticanTraverse", progress: 5),
		(type: .map, filename: "DataMaps_InnerCouncil", progress: 5),
		(type: .map, filename: "DataMaps_OuterCouncil", progress: 5),
		(type: .map, filename: "DataMaps_EarthSystemsAlliance", progress: 5),
		(type: .item, filename: "DataItems_1", progress: 1),
		(type: .item, filename: "DataItems_1Loot", progress: 1),
		(type: .item, filename: "DataItems_1Scans", progress: 1),
		(type: .item, filename: "DataItems_2", progress: 1),
		(type: .item, filename: "DataItems_2Loot", progress: 1),
		(type: .item, filename: "DataItems_3", progress: 1),
		(type: .item, filename: "DataItems_3Loot", progress: 1),
		(type: .item, filename: "DataItems_3Scans", progress: 1),
		(type: .mission, filename: "DataMissions_1", progress: 2),
		(type: .mission, filename: "DataMissions_1Assignments", progress: 5),
		(type: .mission, filename: "DataMissions_1Misc", progress: 3),
		(type: .mission, filename: "DataMissions_2", progress: 2),
		(type: .mission, filename: "DataMissions_2Assignments", progress: 5),
		(type: .mission, filename: "DataMissions_2Misc", progress: 5),
		(type: .mission, filename: "DataMissions_3", progress: 2),
		(type: .mission, filename: "DataMissions_3Assignments", progress: 5),
		(type: .mission, filename: "DataMissions_3Convos", progress: 5),
		(type: .mission, filename: "DataMissions_3Misc", progress: 5),
	]

	func fireProgress(progress: Double, progressTotal: Double) {
		let progressPercent = progressTotal > 0 ? (progress > 0 ? Int((progress / progressTotal) * 100) : 0) : 1
//		print("fireProgress \(progress)/\(progressTotal) \(progressPercent)%")
		DispatchQueue.main.async {
			CoreDataMigrations.onPercentProgress.fire(progressPercent)
		}
	}

	func addData() {
		let progressTotal = progressFiles.map { $0.progress }.reduce(0.0, +)
			+ (progressProcessImportChunk * 2.0) + progressFinalPadding
		importDataFiles(progress: 0.0, progressTotal: progressTotal)
		processImportedData(
			progress: progressTotal - (progressProcessImportChunk * 2.0),
			progressTotal: progressTotal
		)
	}
}

extension BaseDataImport {
	func importDataFiles(progress: Double, progressTotal: Double) {
		var progress = progress
		fireProgress(progress: progress, progressTotal: progressTotal)

		// load up all ids so we know if some have been removed
		var deleteOldIds: [BaseDataFileImportType: [String]] = [:]
		for type in Array(Set(progressFiles.map({ $0.type }))) {
			deleteOldIds[type] = self.getAllIds(type: type, with: manager)
		}

		for row in progressFiles {
			let type = row.type
			let filename = row.filename
			let batchProgress = row.progress
			do {
				if let file = Bundle.main.path(forResource: filename, ofType: "json") {
                    let data = try Data(contentsOf: URL(fileURLWithPath: file))
					let ids = importData(data, with: manager)
					deleteOldIds[type] = Array(Set(deleteOldIds[type] ?? []).subtracting(ids))
				}
			} catch {
				// failure
				deleteOldIds[type] = [] // don't delete any rows
				print("Failed to load file \(filename)")
			}
			progress += batchProgress
			self.fireProgress(progress: progress, progressTotal: progressTotal)
		}

		// remove any old entries not included in this update
		// (this is unsupported in XCTest inMemoryStore)
		if !isTestProject {
			for (type, ids) in deleteOldIds {
				_ = deleteAllIds(type: type, ids: ids, with: manager)
			}
		}
	}

	func processImportedData(progress: Double, progressTotal: Double) {
		fireProgress(progress: progress, progressTotal: progressTotal)

		let queue = DispatchQueue.global(qos: .userInitiated)
		let queueGroup = DispatchGroup()

		var tempProgress1 = 0.0
		var tempProgress2 = 0.0
		let updateProgress1: ((Double, Bool) -> Void) = { (chunkProgress, isCompleted) in
			if isCompleted {
				tempProgress1 = self.progressProcessImportChunk
				self.fireProgress(progress: progress + tempProgress2 + tempProgress1, progressTotal: progressTotal)
			} else {
				tempProgress1 += chunkProgress
				self.fireProgress(
					progress: progress + tempProgress2 + tempProgress1,
					progressTotal: progressTotal
				)
			}
		}
		let updateProgress2: ((Double, Bool) -> Void) = { (chunkProgress, isCompleted) in
			if isCompleted {
				tempProgress2 = self.progressProcessImportChunk
				self.fireProgress(progress: progress + tempProgress2 + tempProgress1, progressTotal: progressTotal)
			} else {
				tempProgress2 += chunkProgress
				self.fireProgress(
					progress: progress + tempProgress2 + tempProgress1,
					progressTotal: progressTotal
				)
			}
		}

		if true || isTestProject {
			// XCTest has some multithreading issues, where the queueGroup wait blocks the Core Data wait. 
			// So we will run it synchronously.
			processImportedMapData(queue: queue, updateProgress: updateProgress1)
			processImportedMissionData(queue: queue, updateProgress: updateProgress2)
		} else {
			// Queue #1
			queueGroup.enter()
			queue.async(group: queueGroup) {
				self.processImportedMapData(queue: queue, updateProgress: updateProgress1)
				queueGroup.leave()
			}
			// Queue #2
			queueGroup.enter()
			queue.async(group: queueGroup) {
				self.processImportedMissionData(queue: queue, updateProgress: updateProgress2)
				queueGroup.leave()
			}
			// wait for finish
			queueGroup.wait()
		}

		// TODO: delete orphan game data?

		fireProgress(progress: progressTotal, progressTotal: progressTotal)
	}
}

extension BaseDataImport {
	func processImportedMapData(
		queue: DispatchQueue,
		updateProgress: @escaping ((Double, Bool) -> Void)
	) {
        let manager = self.manager
		let mapsCount = DataMap.getCount(with: manager)
		var countProcessed: Int = 0
		let chunkSize: Int = 20
		let chunkPercentage = Double(chunkSize) / Double(mapsCount)
		let chunkProgress = Double(self.progressProcessImportChunk) * chunkPercentage

        for map in DataMap.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMapId = nil)")
        }) {
            self.applyInheritedEvents(
                map: map,
                inheritableEvents: map.getInheritableEvents(),
                runOnEachMapBlock: {
                    if countProcessed > 0 && countProcessed % chunkSize == 0 {
                        // notify chunk done
                        queue.sync {
                            updateProgress(chunkProgress, false)
                        }
                    }
                    countProcessed += 1
                }
            )
        }
        // notify all done
        queue.sync {
            updateProgress(0, true)
        }
	}

	func processImportedMissionData(
		queue: DispatchQueue,
		updateProgress: @escaping ((Double, Bool) -> Void)
	) {
        let manager = self.manager
		let missionsCount = DataMission.getCount(with: manager)
		var countProcessed: Int = 0
		let chunkSize: Int = 20
		let chunkPercentage = Double(chunkSize) / Double(missionsCount)
		let chunkProgress = Double(self.progressProcessImportChunk) * chunkPercentage

        for mission in DataMission.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMissionId = nil)")
        }) {
            self.applyInheritedEvents(
                mission: mission,
                inheritableEvents: mission.getInheritableEvents(),
                runOnEachMissionBlock: {
                    if countProcessed > 0 && countProcessed % chunkSize == 0 {
                        // notify chunk done
                        queue.sync {
                            updateProgress(chunkProgress, false)
                        }
                    }
                    countProcessed += 1
                }
            )
        }
        // notify all done
        queue.sync {
            updateProgress(0, true)
        }
	}

	//TODO: Protocol events and generic this function
	// Note: items and persons don't inherit, so ignore them here

	func applyInheritedEvents(
		map: DataMap,
		inheritableEvents: [CodableDictionary],
		level: Int = 0,
		runOnEachMapBlock: @escaping (() -> Void)
	) {
        var maps: [DataMap] = []
        for (var childMap) in DataMap.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMapId = %@)", map.id)
        }) {
            var eventData = childMap.rawEventDictionary.map { $0.dictionary }
            var isChanged = false
            for event in inheritableEvents where !eventData.contains(where: {
                $0["id"] as? String == event["id"] as? String && $0["type"] as? String == event["type"] as? String
            }) {
                eventData.append(event.dictionary)
                isChanged = true
            }
            var childInheritableEvents = inheritableEvents + childMap.getInheritableEvents()
            while let index = eventData.index(where: { $0["eraseParentValue"] as? Bool == true }) {
                let event = eventData.remove(at: index)
                if let index2 = childInheritableEvents.index(where: { event["id"] as? String == $0["id"] as? String }) {
                    childInheritableEvents.remove(at: index2)
                }
                isChanged = true
            }
            if isChanged {
                childMap.rawEventDictionary = eventData.map { CodableDictionary($0) }
                maps.append(childMap)
            }
            runOnEachMapBlock()
            self.applyInheritedEvents(
                map: childMap,
                inheritableEvents: childInheritableEvents,
                level: level + 1,
                runOnEachMapBlock: runOnEachMapBlock
            )
        }
        _ = DataMap.saveAll(items: maps, with: manager)

        var items: [DataItem] = []
        for (var childItem) in DataItem.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMapId = %@)", map.id)
        }) {
            var eventData = childItem.rawEventDictionary.map { $0.dictionary }
            var isChanged = false
            for event in inheritableEvents where !eventData.contains(where: {
                $0["id"] as? String == event["id"] as? String && $0["type"] as? String == event["type"] as? String
            }) {
                eventData.append(event.dictionary)
                isChanged = true
            }
            while let index = eventData.index(where: { $0["eraseParentValue"] as? Bool == true }) {
                eventData.remove(at: index)
                isChanged = true
            }
            if isChanged {
                childItem.rawEventDictionary = eventData.map { CodableDictionary($0) }
                items.append(childItem)
            }
            // no child item inheritance
        }
        _ = DataItem.saveAll(items: items, with: manager)
	}

	func applyInheritedEvents(
		mission: DataMission,
		inheritableEvents: [CodableDictionary],
		level: Int = 0,
		runOnEachMissionBlock: @escaping (() -> Void)
	) {
        var missions: [DataMission] = []
        for (var childMission) in DataMission.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMissionId = %@)", mission.id)
        }) {
            var eventData = childMission.rawEventDictionary.map { $0.dictionary }
            var isChanged = false
            for event in inheritableEvents where !eventData.contains(where: {
                $0["id"] as? String == event["id"] as? String && $0["type"] as? String == event["type"] as? String
            }) {
                eventData.append(event.dictionary)
                isChanged = true
            }
            var childInheritableEvents = inheritableEvents + childMission.getInheritableEvents()
            while let index = eventData.index(where: { $0["eraseParentValue"] as? Bool == true }) {
                let event = eventData.remove(at: index)
                if let index2 = childInheritableEvents.index(where: { event["id"] as? String == $0["id"] as? String }) {
                    childInheritableEvents.remove(at: index2)
                }
                isChanged = true
            }
            if isChanged {
                childMission.rawEventDictionary = eventData.map { CodableDictionary($0) }
                missions.append(childMission)
            }
            runOnEachMissionBlock()
            self.applyInheritedEvents(
                mission: childMission,
                inheritableEvents: childInheritableEvents,
                level: level + 1,
                runOnEachMissionBlock: runOnEachMissionBlock
            )
        }
        _ = DataMission.saveAll(items: missions, with: manager)

        var items: [DataItem] = []
        for (var childItem) in DataItem.getAll(with: manager, alterFetchRequest: { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(inMissionId = %@)", mission.id)
        }) {
            var eventData = childItem.rawEventDictionary.map { $0.dictionary }
            var isChanged = false
            for event in inheritableEvents where !eventData.contains(where: {
                $0["id"] as? String == event["id"] as? String && $0["type"] as? String == event["type"] as? String
            }) {
                eventData.append([
                    "id": event["id"] as? String,
                    "type": event["type"] as? String,
                    "eraseParentValue": event["eraseParentValue"] as? Bool ?? false,
                ])
                isChanged = true
            }
            while let index = eventData.index(where: { $0["eraseParentValue"] as? Bool == true }) {
                eventData.remove(at: index)
                isChanged = true
            }
            if isChanged {
                childItem.rawEventDictionary = eventData.map { CodableDictionary($0) }
                items.append(childItem)
            }
            // no child item inheritance
        }
        _ = DataItem.saveAll(items: items, with: manager)
    }
}
