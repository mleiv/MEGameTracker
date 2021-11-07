//
//  CoreDataMigrationType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/1/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

public protocol CoreDataMigrationType {
	func run() throws
}

extension CoreDataMigrationType {

	public func clearData(
		types: [BaseDataFileImportType],
		with manager: CodableCoreDataManageable? = nil
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
		with manager: CodableCoreDataManageable? = nil
	) -> [String] {
		switch type {
		case .decision:
            return DataDecision.getAllIds(with: manager)
        case .event:
            return DataEvent.getAllIds(with: manager)
		case .item: return DataItem.getAllIds(with: manager)
		case .map: return DataMap.getAllIds(with: manager)
		case .mission: return DataMission.getAllIds(with: manager)
		case .person: return DataPerson.getAllIds(with: manager)
		}
	}

	public func deleteAllIds(
		type: BaseDataFileImportType, ids: [String],
		with manager: CodableCoreDataManageable? = nil
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
		_ data: Data?,
		with manager: CodableCoreDataManageable? = nil
	) throws -> [String] {
        let manager = manager ?? CoreDataManager.current
        guard let data = data else { return [] }
        if let dataImport = try? manager.decoder.decode(DecisionsImport.self, from: data) {
            return dataImport.saveAndGetIds(with: manager)
        }
        if let dataImport = try? manager.decoder.decode(EventsImport.self, from: data) {
            return dataImport.saveAndGetIds(with: manager)
        }
        if let dataImport = try? manager.decoder.decode(ItemsImport.self, from: data) {
            return dataImport.saveAndGetIds(with: manager)
        }
        if let dataImport = try? manager.decoder.decode(MapsImport.self, from: data) {
            let rows = dataImport.saveAndGetIds(with: manager)
            return rows
        }
        if let dataImport = try? manager.decoder.decode(MissionsImport.self, from: data) {
            return dataImport.saveAndGetIds(with: manager)
        }
        if let dataImport = try? manager.decoder.decode(PersonsImport.self, from: data) {
            return dataImport.saveAndGetIds(with: manager)
        }
        throw CoreDataMigration.MigrationError.invalidJson
	}
}

protocol CoreDataMigrationImportSet {
    associatedtype DataRowType: DataRowStorable
    var rows: [DataRowType] { get }
    func saveAndGetIds(
        with manager: CodableCoreDataManageable?
    ) -> [String]
}
extension CoreDataMigrationImportSet {
	func saveAndGetIds(
		with manager: CodableCoreDataManageable?
	) -> [String] {
		_ = DataRowType.saveAll(items: rows, with: manager)
		return rows.map { $0.id }
	}
}

struct DecisionsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataDecision
    enum CodingKeys: String, CodingKey { case decisions }
    var rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .decisions)
    }
}
struct EventsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataEvent
    enum CodingKeys: String, CodingKey { case events }
    var rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .events)
    }
}
struct ItemsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataItem
    enum CodingKeys: String, CodingKey { case items }
    var rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .items)
    }
}
struct MapsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataMap
    enum CodingKeys: String, CodingKey { case maps }
    var rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .maps)
    }
}
struct MissionsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataMission
    enum CodingKeys: String, CodingKey { case missions }
    var rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .missions)
    }
}
struct PersonsImport: Decodable, CoreDataMigrationImportSet {
    typealias DataRowType = DataPerson
    enum CodingKeys: String, CodingKey { case persons }
    let rows: [DataRowType]
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rows = try container.decode([DataRowType].self, forKey: .persons)
    }
}
