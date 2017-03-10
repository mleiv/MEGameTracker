//
//  CoreDataMigrationType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/1/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

public protocol CoreDataMigrationType {
	func run()
}

extension CoreDataMigrationType {

	public func clearData(
		types: [BaseDataFileImportType],
		with manager: SimpleSerializedCoreDataManageable? = nil
	) {
		types.forEach {
			switch $0 {
			case .decision:
				_ = DataDecision.deleteAll(with: manager)
			case .event:
				_ = DataEvent.deleteAll(with: manager)
			case .item:
				_ = DataItem.deleteAll(with: manager)
			case .map:
				_ = DataMap.deleteAll(with: manager)
			case .mission:
				_ = DataMission.deleteAll(with: manager)
			case .person:
				_ = DataPerson.deleteAll(with: manager)
			}
		}
	}

	public func getAllIds(
		type: BaseDataFileImportType,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [String] {
		switch type {
		case .decision: return DataDecision.getAllIds(with: manager)
		case .event: return DataEvent.getAllIds(with: manager)
		case .item: return DataItem.getAllIds(with: manager)
		case .map: return DataMap.getAllIds(with: manager)
		case .mission: return DataMission.getAllIds(with: manager)
		case .person: return DataPerson.getAllIds(with: manager)
		}
	}

	public func deleteAllIds(
		type: BaseDataFileImportType, ids: [String],
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		switch type {
		case .decision:
			return DataDecision.deleteAll(ids: ids, with: manager) && Decision.deleteOrphans(with: manager)
		case .event:
			return DataEvent.deleteAll(ids: ids, with: manager) && Event.deleteOrphans(with: manager)
		case .item:
			return DataItem.deleteAll(ids: ids, with: manager) && Item.deleteOrphans(with: manager)
		case .map:
			return DataMap.deleteAll(ids: ids, with: manager) && Map.deleteOrphans(with: manager)
		case .mission:
			return DataMission.deleteAll(ids: ids, with: manager) && Mission.deleteOrphans(with: manager)
		case .person:
			return DataPerson.deleteAll(ids: ids, with: manager) && Person.deleteOrphans(with: manager)
		}
	}

	public func importData(
		_ data: SerializableData,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [String] {
		for (key, values) in data.dictionary  ?? [:] {
			guard let type = BaseDataFileImportType(jsonValue: key) else { continue }
			switch type {
				case .decision: return CoreDataMigrationImportSet<DataDecision>(values.array ?? []).save(with: manager)
				case .event: return CoreDataMigrationImportSet<DataEvent>(values.array ?? []).save(with: manager)
				case .item: return CoreDataMigrationImportSet<DataItem>(values.array ?? []).save(with: manager)
				case .map: return CoreDataMigrationImportSet<DataMap>(values.array ?? []).save(with: manager)
				case .mission: return CoreDataMigrationImportSet<DataMission>(values.array ?? []).save(with: manager)
				case .person: return CoreDataMigrationImportSet<DataPerson>(values.array ?? []).save(with: manager)
			}
		}
		return []
	}
}

struct CoreDataMigrationImportSet<T: DataRowStorable> {
	var items: [T]
	init(_ dataRows: [SerializableData]) {
		items = dataRows.flatMap { T(data: $0) }
	}
	func save(
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [String] {
		_ = T.saveAll(items: items, with: manager)
		return items.map { $0.id }
	}
}
