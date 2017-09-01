//
//  Map.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

public struct Map: Codable, MapLocationable, Eventsable {

    enum CodingKeys: String, CodingKey {
        case id
        case isExplored
    }

// MARK: Constants

// MARK: Properties
	public var generalData: DataMap

	public private(set) var id: String
	public private(set) var gameVersion: GameVersion
	private var _annotationNote: String?

	/// (GameModifying, GameRowStorable Protocol) 
	/// This value's game identifier.
	public var gameSequenceUuid: UUID?
	/// (DateModifiable Protocol)  
	/// Date when value was created.
	public var createdDate = Date()
	/// (DateModifiable Protocol)  
	/// Date when value was last changed.
	public var modifiedDate = Date()
	/// (CloudDataStorable Protocol)  
	/// Flag for whether the local object has changes not saved to the cloud.
	public var isSavedToCloud = false
	/// (CloudDataStorable Protocol)  
	/// A set of any changes to the local object since the last cloud sync.
    public var pendingCloudChanges = CodableDictionary()
	/// (CloudDataStorable Protocol)  
	/// A copy of the last cloud kit record.
	public var lastRecordData: Data?

	// Eventsable
	private var _events: [Event]?
	public var events: [Event] {
		get { return _events ?? getEvents() } // cache?
		set { _events = newValue }
	}
    public var rawEventData: [CodableDictionary] { return generalData.rawEventData }

	public internal(set) var isExplored: Bool {
        get {
            return isExploredPerGameVersion[gameVersion] ?? false
        }
        set {
            isExploredPerGameVersion[gameVersion] = newValue
        }
	}
	public internal(set) var isExploredPerGameVersion: [GameVersion: Bool] = [:]

// MARK: Computed Properties

	public var name: String { return generalData.name }
	public var description: String? { return generalData.description }
	public var image: String? { return generalData.image }
	public var referenceSize: CGSize? { return generalData.referenceSize }
	public var mapType: MapType { return generalData.mapType }
	public var isMain: Bool { return generalData.isMain }
	public var isSplitMenu: Bool { return generalData.isSplitMenu }
	public var relatedLinks: [String] { return generalData.relatedLinks }
	public var sideEffects: [String] { return generalData.sideEffects }
	public var relatedMissionIds: [String] { return generalData.relatedMissionIds }
	public var isExplorable: Bool { return generalData.isExplorable }

	public var parentMap: Map? {
		if let id = inMapId {
			var parentMap = Map.get(id: id)
			parentMap?.change(gameVersion: gameVersion, isSave: false, isNotify: false)
			return parentMap
		}
		return nil
	}

	/// **Warning:** no changes are saved.
	public var relatedDecisionIds: [String] {
		// Changing the value of decisionIds does not get saved.
		// This is only for refreshing local data without a core data call.
		get { return generalData.relatedDecisionIds }
		set { generalData.relatedDecisionIds = newValue }
	}

	public func isAvailableInGame(_ gameVersion: GameVersion) -> Bool {
		return generalData.isAvailable && events.filter({ (e: Event) in
			return e.type == .unavailableInGame ? e.isBlockingInGame(gameVersion) : false
		}).isEmpty
	}

// MARK: MapLocationable

	public var annotationNote: String? {
		get { return _annotationNote ?? generalData.annotationNote }
		set { _annotationNote = newValue }
	}

	public var mapLocationType: MapLocationType {
        return generalData.mapLocationType
    }
	public var mapLocationPoint: MapLocationPoint? {
		get { return generalData.mapLocationPoint }
		set { generalData.mapLocationPoint = newValue }
	}
	public var inMapId: String? {
		get { return generalData.inMapId }
		set { generalData.inMapId = newValue }
	}
	public var inMissionId: String? {
        get { return generalData.inMissionId }
        set { generalData.inMissionId = newValue }
    }
	public var sortIndex: Int {
        get { return generalData.sortIndex }
        set {}
    }

	public var isHidden: Bool {
        get { return generalData.isHidden }
        set {}
    }
	public var isAvailable: Bool {
        get {
            return generalData.isAvailable && events.filter({ (e: Event) in
                return e.isBlockingInGame(gameVersion)
            }).isEmpty
        }
        set {}
    }
	public var unavailabilityMessages: [String] {
        get {
            let blockingEvents = events.filter({ (e: Event) in return e.isBlockingInGame(App.current.gameVersion) })
            if !blockingEvents.isEmpty {
                if let unavailabilityInGameMessage = blockingEvents.filter({ (e: Event) -> Bool in
                        return e.type == .unavailableInGame
                    }).first?.description,
                    !unavailabilityInGameMessage.isEmpty {
                    return generalData.unavailabilityMessages + [unavailabilityInGameMessage]
                } else {
                    return generalData.unavailabilityMessages
                        + blockingEvents.map({ $0.description }).filter({ $0 != nil }).map({ $0! })
                }
            }
            return generalData.unavailabilityMessages
        }
        set {}
	}

	public var linkToMapId: String? { return generalData.linkToMapId }
	public var shownInMapId: String?
	public var isShowInParentMap: Bool = false
	public var isShowInList: Bool { return generalData.isShowInList }
	public var isShowPin: Bool { return generalData.isShowPin }
	public var isOpensDetail: Bool { return generalData.isOpensDetail }

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Map?)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: UUID? = App.current.game?.uuid,
		gameVersion: GameVersion? = nil,
		generalData: DataMap,
		events: [Event] = [],
		data: SerializableData? = nil
	) {
		self.id = id
		self.gameSequenceUuid = gameSequenceUuid
		self.gameVersion = gameVersion ?? generalData.gameVersion
		self.generalData = generalData
		self.events = events
        setGeneralData()
    }

    public mutating func setGeneralData() {
        // nothing for now
    }
    public mutating func setGeneralData(_ generalData: DataMap) {
        self.generalData = generalData
        setGeneralData()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameVersion = .game1
        generalData = DataMap(id: id) // faulted for now
        isExplored = try container.decodeIfPresent(Bool.self, forKey: .isExplored) ?? isExplored
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isExplored, forKey: .isExplored)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension Map {

	public func getBreadcrumbs() -> [AbbreviatedMapData] {
		return generalData.getBreadcrumbs()
	}

	public func getCompleteBreadcrumbs() -> [AbbreviatedMapData] {
		return generalData.getCompleteBreadcrumbs()
	}

	public func getMapLocations() -> [MapLocationable] {
		return MapLocation.getAll(inMapId: id, gameVersion: gameVersion).sorted(by: MapLocation.sort)
	}

//	public func getMissions(isCompleted: Bool? = nil) -> [Mission] {
//		let missions = MapLocation.getAllMissions(inMapId: id, gameVersion: gameVersion).flatMap { $0 as? Mission }

//		if let isCompleted = isCompleted {
//			return missions.filter { $0.isCompleted == isCompleted }.sorted(by: Mission.sort)
//		}

//		return missions
//	}

//	
//	public func getMissionsRatio(missions: [Mission]) -> String {
//		let acquired = missions.filter { $0.isCompleted }.count
//		let pending = missions.count - acquired
//		return "\(acquired)/\(pending)"
//	}

//	
//	public func getItems(isAcquired: Bool? = nil) -> [Item] {
//		let items = MapLocation.getAllItems(inMapId: id, gameVersion: gameVersion).flatMap { $0 as? Item }

//		if let isAcquired = isAcquired {
//			return items.filter { $0.isAcquired == isAcquired }.sorted(by: Item.sort)
//		}

//		return items
//	}

//	
//	public func getItemsRatio(items: [Item]) -> String {
//		let acquired = items.filter { $0.isAcquired }.count
//		let pending = items.count - acquired
//		return "\(acquired)/\(pending)"
//	}

//	

	public func getChildMaps(isExplored: Bool? = nil) -> [Map] {
		let maps = MapLocation.getAllMaps(inMapId: id, gameVersion: gameVersion)
            .map({ $0 as? Map }).filter({ $0 != nil }).map({ $0! })
		if let isExplored = isExplored {
			return maps.filter { $0.isExplored == isExplored }.sorted(by: Map.sort)
		}
		return maps
	}

	/// Notesable source data
	public func getNotes(completion: @escaping (([Note]) -> Void) = { _ in }) {
		let id = self.id
		DispatchQueue.global(qos: .background).async {
			completion(Note.getAll(identifyingObject: .map(id: id)))
		}
	}

}

// MARK: Basic Actions
extension Map {

	/// - Returns: A new note object tied to this object
	public func newNote() -> Note {
		return Note(identifyingObject: .map(id: id))
	}

}

// MARK: Data Change Actions
extension Map {

	public mutating func change(
		gameVersion: GameVersion,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard self.gameVersion != gameVersion else { return }
		self.gameVersion = gameVersion
		generalData = generalData.changed(gameVersion: gameVersion)
		// no save
		if isNotify {
			Map.onChange.fire((id: self.id, object: self))
		}
	}

	public mutating func change(
		isExplored: Bool,
		isSave: Bool = true,
		isNotify: Bool = true,
		isCascadeChanges: EventDirection = .all
	) {
		guard self.isExplored != isExplored else { return }
		self.isExplored = isExplored
		markChanged()
		notifySaveToCloud(fields: ["isExplored": isExplored])
		if isSave {
			_ = saveAnyChanges()
		}
		if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
			applyToHierarchy(isExplored: isExplored, isSave: isSave, isCascadeChanges: isCascadeChanges)
		}
		if isNotify {
			Map.onChange.fire((id: self.id, object: self))
		}
	}

	private mutating func applyToHierarchy(
		isExplored: Bool,
		isSave: Bool,
		isCascadeChanges: EventDirection = .all
	) {
		let maps = getChildMaps()
		if isCascadeChanges != .up {
			for childMap in maps where childMap.isExplorable && childMap.isExplored != isExplored {
				// complete/uncomplete all submaps if parent was just completed/uncompleted
				var childMap = childMap
				childMap.change(isExplored: isExplored, isSave: isSave, isCascadeChanges: .down)
			}
		}
		if isCascadeChanges != .down, var parentMap = self.parentMap, parentMap.isExplorable {
			let siblingMaps = parentMap.getChildMaps()
			if !isExplored && parentMap.isExplored {
				// uncomplete parent
				// don't uncomplete other children
				parentMap.change(isExplored: false, isSave: isSave, isCascadeChanges: .up)
			} else if isExplored && !parentMap.isExplored && !siblingMaps.isEmpty {
				let exploredCount = siblingMaps.filter({ $0 == self })
					.filter({ $0.isExplorable && $0.isExplored }).count + 1
				if exploredCount == siblingMaps.count {
					// complete parent
					parentMap.change(isExplored: true, isSave: isSave, isCascadeChanges: .up)
				}
			}
		}
	}
}

// MARK: Dummy data for Interface Builder
extension Map {
	public static func getDummy(json: String? = nil) -> Map? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\":\"1\",\"gameVersion\":\"1\",\"name\":\"Sahrabarik\"}"
        if var baseMap = try? defaultManager.decoder.decode(DataMap.self, from: json.data(using: .utf8)!) {
            baseMap.isDummyData = true
            let map = Map(id: "1", generalData: baseMap)
            return map
        }
		// swiftlint:enable line_length
		return nil
	}
}

//// MARK: SerializedDataStorable
//extension Map: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        var list: [String: SerializedDataStorable?] = [:]
//        list["id"] = id
//        list["isExplored"] = gameValuesForIsExplored()
////        list = serializeDateModifiableData(list: list)
////        list = serializeGameModifyingData(list: list)
////        list = serializeLocalCloudData(list: list)
//        return SerializableData.safeInit(list)
//    }
//
//    public func gameValuesForIsExplored() -> String {
//        var data: [String] = []
//        for game in GameVersion.all() {
//            data.append(isExploredPerGameVersion[game] == true ? "1" : "0")
//        }
//        return "|\(data.joined(separator: "|"))|"
//    }
//
//}

// MARK: SerializedDataRetrievable
//extension Map: SerializedDataRetrievable {

//    public init?(data: SerializableData?) {
//        let gameVersion = GameVersion(rawValue: data?["gameVersion"]?.string ?? "0") ?? .game1
//        guard let data = data, let id = data["id"]?.string,
//              let dataMap = DataMap.get(id: id, gameVersion: gameVersion),
//              let uuidString = data["gameSequenceUuid"]?.string,
//              let gameSequenceUuid = UUID(uuidString: uuidString)
//        else {
//            return nil
//        }
//
//        self.init(
//            id: id,
//            gameSequenceUuid: gameSequenceUuid,
//            gameVersion: gameVersion,
//            generalData: dataMap,
//            data: data
//        )
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
//            self.gameVersion = gameVersion
//            generalData.change(gameVersion: gameVersion)
////            _events = nil
//        }
//        if generalData.id != id {
//            generalData = DataMap.get(id: id, gameVersion: gameVersion) ?? generalData
//            _events = nil
//        }
//
////        unserializeDateModifiableData(data: data)
////        unserializeGameModifyingData(data: data)
////        unserializeLocalCloudData(data: data)
//
//        isExploredPerGameVersion = gameValuesFromIsExplored(data: data["isExplored"]?.string ?? "")
//    }
//
//    public func gameValuesFromIsExplored(data: String) -> [GameVersion: Bool] {
//        let pieces = data.components(separatedBy: "|")
//        if pieces.count == 5 {
//            var values: [GameVersion: Bool] = [:]
//            values[.game1] = pieces[1] == "1"
//            values[.game2] = pieces[2] == "1"
//            values[.game3] = pieces[3] == "1"
//            return values
//        }
//        return [.game1: false, .game2: false, .game3: false]
//    }
//
//}

// MARK: DateModifiable
extension Map: DateModifiable {}

// MARK: GameModifying
extension Map: GameModifying {}

// MARK: Sorting
extension Map {

	static func sort(_ first: Map, _ second: Map) -> Bool {
		if first.inMapId == nil && second.inMapId != nil {
			return true
		} else if first.isExplored != second.isExplored {
			return second.isExplored // push to end
		} else if first.isAvailable != second.isAvailable {
			return first.isAvailable // push to start
		} else {
			return first.name < second.name // still unsure - all the others sort by id.
		}
	}
}

// MARK: Equatable
extension Map: Equatable {
	public static func == (_ lhs: Map, _ rhs: Map) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Map: Hashable {
	public var hashValue: Int { return id.hashValue }
}
// swiftlint:enable file_length
