//
//  Shepard.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

public struct Shepard: Codable, Photographical {

    enum CodingKeys: String, CodingKey {
        case uuid
        case gameSequenceUuid
        case gameVersion
        case gender
        case appearance
        case name
        case origin
        case reputation
        case classTalent = "class"
        case level
        case paragon
        case renegade
        case photo
        case loveInterestId
    }

// MARK: Constants
	public static let DefaultSurname = "Shepard"

// MARK: Properties
	public var id: UUID { return uuid }
	public internal(set) var uuid: UUID

	/// (GameModifying Protocol) 
	/// This value's game identifier.
	public var gameSequenceUuid: UUID

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

	public private(set) var gameVersion: GameVersion

	public private(set) var gender = Gender.male
	public private(set) var name = Name.defaultMaleName
	public private(set) var photo: Photo?
	public private(set) var appearance: Appearance
	public private(set) var origin = Origin.earthborn
	public private(set) var reputation = Reputation.soleSurvivor
	public private(set) var classTalent = ClassTalent.soldier
	public private(set) var loveInterestId: String?
	public private(set) var level: Int = 1
	public private(set) var paragon: Int = 0
	public private(set) var renegade: Int = 0

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties
	public var title: String {
		return "\(origin.stringValue) \(reputation.stringValue) \(classTalent.stringValue)"
	}
	public var fullName: String { return "\(name.stringValue!) Shepard" }
	public var photoFileNameIdentifier: String {
		return Shepard.getPhotoFileNameIdentifier(uuid: uuid)
	}
	public static func getPhotoFileNameIdentifier(uuid: UUID) -> String {
		return "MyShepardPhoto\(uuid.uuidString)"
	}

// MARK: Change Listeners And Change Status Flags
	public var isNew: Bool = false

	/// (DateModifiable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	/// Don't use this. Use App.onCurrentShepardChange instead.
	public static let onChange = Signal<(id: String, object: Shepard)>()

// MARK: Initialization
	/// Created by App
	public init(gameSequenceUuid: UUID, uuid: UUID = UUID(), gender: Shepard.Gender = .male, gameVersion: GameVersion = .game1) {
        self.uuid = uuid
		self.gameSequenceUuid = gameSequenceUuid
		self.gender = gender
		self.gameVersion = gameVersion
		appearance = Appearance(gameVersion: gameVersion)
		photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
		markChanged()
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        gameSequenceUuid = try container.decode(UUID.self, forKey: .gameSequenceUuid)
        gameVersion = try container.decode(GameVersion.self, forKey: .gameVersion)
        gender = try container.decode(Shepard.Gender.self, forKey: .gender)
        if let appearanceString = try container.decodeIfPresent(String.self, forKey: .appearance) {
            appearance = Appearance(appearanceString, fromGame: gameVersion, withGender: gender)
        } else {
            appearance = Appearance(gameVersion: gameVersion)
        }
        let nameString = try container.decode(String.self, forKey: .name)
        name = Shepard.Name(name: nameString, gender: gender) ?? name
        origin = try container.decode(Shepard.Origin.self, forKey: .origin)
        reputation = try container.decode(Shepard.Reputation.self, forKey: .reputation)
        classTalent = try container.decode(Shepard.ClassTalent.self, forKey: .classTalent)
        level = (try container.decodeIfPresent(Int.self, forKey: .level)) ?? level
        paragon = (try container.decodeIfPresent(Int.self, forKey: .paragon)) ?? paragon
        renegade = (try container.decodeIfPresent(Int.self, forKey: .renegade)) ?? renegade
        if let photoPath = try container.decodeIfPresent(String.self, forKey: .photo),
            let photo = Photo(filePath: photoPath) {
            self.photo = photo
        } else {
            photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
        }
        loveInterestId = try container.decodeIfPresent(String.self, forKey: .loveInterestId)
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(gameSequenceUuid, forKey: .gameSequenceUuid)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(gender, forKey: .gender)
        try container.encode(appearance.format(), forKey: .appearance)
        try container.encode(name.stringValue, forKey: .name)
        try container.encode(origin, forKey: .origin)
        try container.encode(reputation, forKey: .reputation)
        try container.encode(classTalent, forKey: .classTalent)
        try container.encode(level, forKey: .level)
        try container.encode(paragon, forKey: .paragon)
        try container.encode(renegade, forKey: .renegade)
        try container.encode(photo?.isCustomSavedPhoto == true ? photo?.stringValue : nil, forKey: .photo)
        try container.encode(loveInterestId, forKey: .loveInterestId)
        try serializeDateModifiableData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension Shepard {

	/// - Returns: Current Person love interest for the shepard and gameVersion
	public mutating func getLoveInterest() -> Person? {
		if let loveInterestId = self.loveInterestId {
			return Person.get(id: loveInterestId, gameVersion: gameVersion)
		}
		return nil
	}

	/// Notesable source data
	public func getNotes(completion: @escaping (([Note]) -> Void) = { _ in }) {
		DispatchQueue.global(qos: .background).async {
			completion(Note.getAll(identifyingObject: .shepard))
		}
	}
}

// MARK: Basic Actions
extension Shepard {

	/// - Returns: A new note object tied to this object
	public func newNote() -> Note {
		return Note(identifyingObject: .shepard)
	}

	/// A special setter for saving a UIImage
	public mutating func savePhoto(image: UIImage, isSave: Bool = true) -> Bool {
		if let photo = Photo.create(image, object: self) {
			change(photo: photo, isSave: isSave)
			return true
		}
		return false
	}
}

// MARK: Data Change Actions
extension Shepard {

	/// **Warning**: this changes a lot of data and takes a long time
	public mutating func change(
		gender: Gender,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard gender != self.gender else { return }
		let loveInterest: Person? = getLoveInterest()
		var changedFields: [String: SerializedDataStorable?] = [:]
		changedFields["gender"] = gender == .male ? "M" : "F"
		self.gender = gender
		switch gender {
		case .male:
			if name == .defaultFemaleName {
				name = .defaultMaleName
				changedFields["name"] = name.stringValue
			}
			if photo?.isCustomSavedPhoto != true {
				let path = Shepard.PhotoPath.defaultPath(forGender: .male, forGameVersion: gameVersion)
				photo = Photo(filePath: path)
				changedFields["photo"] = photo?.stringValue
			}
			appearance.gender = gender
			changedFields["appearance"] = appearance.format()
			if loveInterest?.isMaleLoveInterest != true {
				change(loveInterestId: nil, isSave: isSave, isNotify: false)
				changedFields["loveInterestId"] = nil
			}
		case .female:
			if name == .defaultMaleName {
				name = .defaultFemaleName
				changedFields["name"] = name.stringValue
			}
			if photo?.isCustomSavedPhoto != true {
				let path = Shepard.PhotoPath.defaultPath(forGender: .female, forGameVersion: gameVersion)
				photo = Photo(filePath: path)
				changedFields["photo"] = photo?.stringValue
			}
			appearance.gender = gender
			changedFields["appearance"] = appearance.format()
			if loveInterest?.isFemaleLoveInterest != true {
				change(loveInterestId: nil, isSave: isSave, isNotify: false)
				changedFields["loveInterestId"] = nil
			}
		}
		markChanged()
		notifySaveToCloud(fields: changedFields)
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		name: String?,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard name != self.name.stringValue else { return }
		self.name = Name(name: name, gender: gender) ?? self.name
		markChanged()
		notifySaveToCloud(fields: ["name": self.name.stringValue])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		photo: Photo,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard photo != self.photo else { return }
		if let photo = self.photo {
			_ = photo.delete()
		}
		self.photo = photo
		markChanged()
		notifySaveToCloud(fields: ["photo": photo.stringValue])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		appearance: Appearance,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard appearance != self.appearance else { return }
		self.appearance = appearance
		markChanged()
		notifySaveToCloud(fields: ["appearance": appearance.format()])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		origin: Origin,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard origin != self.origin else { return }
		self.origin = origin
		markChanged()
		notifySaveToCloud(fields: ["origin": origin.stringValue])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		reputation: Reputation,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard reputation != self.reputation else { return }
		self.reputation = reputation
		markChanged()
		notifySaveToCloud(fields: ["reputation": reputation.stringValue])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		class classTalent: ClassTalent,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		if classTalent != self.classTalent {
			self.classTalent = classTalent
			markChanged()
			notifySaveToCloud(fields: ["class": classTalent.stringValue])
			if isSave {
				_ = saveAnyChanges(isAllowDelay: false)
			}
			if isNotify {
				Shepard.onChange.fire((id: uuid.uuidString, object: self))
			}
		}
	}

	public mutating func change(
		loveInterestId: String?,
		isSave: Bool = true,
		isNotify: Bool = true,
		isCascadeChanges: EventDirection = .all
	) {
		guard loveInterestId != self.loveInterestId else { return }
		// cascade change to decision
		if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
			if let loveInterestId = loveInterestId,
				let person = Person.get(id: loveInterestId),
				let decisionId = person.loveInterestDecisionId,
				var decision = Decision.get(id: decisionId) {
				// switch selected love interest
				decision.change(
					isSelected: true,
					isSave: isSave,
					isNotify: isNotify,
					isCascadeChanges: .none
				)
			} else if loveInterestId == nil,
				let loveInterestId = self.loveInterestId,
				let person = Person.get(id: loveInterestId),
				let decisionId = person.loveInterestDecisionId,
				var decision = Decision.get(id: decisionId) {
				// erase unselected love interest
				decision.change(
					isSelected: false,
					isSave: isSave,
					isNotify: isNotify,
					isCascadeChanges: .none
				)
			}
		}
		self.loveInterestId = loveInterestId
		markChanged()
		notifySaveToCloud(fields: ["loveInterestId": loveInterestId])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		level: Int,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard level != self.level else { return }
		self.level = level
		markChanged()
		notifySaveToCloud(fields: ["level": level])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		paragon: Int,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard paragon != self.paragon else { return }
		self.paragon = paragon
		markChanged()
		notifySaveToCloud(fields: ["paragon": paragon])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

	public mutating func change(
		renegade: Int,
		isSave: Bool = true,
		isNotify: Bool = true
	) {
		guard renegade != self.renegade else { return }
		self.renegade = renegade
		markChanged()
		notifySaveToCloud(fields: ["renegade": renegade])
		if isSave {
			_ = saveAnyChanges(isAllowDelay: false)
		}
		if isNotify {
			Shepard.onChange.fire((id: uuid.uuidString, object: self))
		}
	}

}

// MARK: Dummy data for Interface Builder
extension Shepard {
	public static func getDummy(json: String? = nil) -> Shepard? {
		// swiftlint:disable line_length
		let json = json ?? "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"
		// swiftlint:enable line_length
		return try? CoreDataManager2.current.decoder.decode(Shepard.self, from: json.data(using: .utf8)!)
	}
}

// MARK: Shared Data
extension Shepard {
    public func getSharedData() -> [String: Any?] {
        var list: [String: Any?] = [:]
        list["gameVersion"] = gameVersion
        list["gender"] = gender
        list["name"] = name
        list["origin"] = origin
        list["reputation"] = reputation
        list["class"] = classTalent
        list["appearance"] = appearance
        list["photo"] = photo?.isCustomSavedPhoto == true ? photo : nil
        return list
    }

    /// Called by app when creating a new gameVersion of an existing shepard - copy over all the general shared choices.
    public mutating func setNewData(oldData: [String: Any?]) {
        setCommonData(oldData)
        // only do when converting to a new game version:
        if var oldAppearance = oldData["appearance"] as? Appearance {
            oldAppearance.convert(toGame: gameVersion) // TODO: immutable chained convert
            appearance = oldAppearance
        }
        classTalent = (oldData["class"] as? ClassTalent) ?? classTalent
        photo = (oldData["photo"] as? Photo) ?? photo
    }

    public mutating func setCommonData(_ data: [String: Any?], isInternal: Bool = false) {
        // make sure to notify these changes to cloud
        var changed: [String: Any?] = [:]
        if let gender = data["gender"] as? Gender, gender != self.gender {
            self.gender = gender
            changed["gender"] = gender.stringValue
        }
        if let name = data["name"] as? Name, name != self.name {
            self.name = name
            changed["name"] = name.stringValue
        }
        if let origin = data["origin"] as? Origin, origin != self.origin {
            self.origin = origin
            changed["origin"] = origin.stringValue
        }
        if let reputation = data["reputation"] as? Reputation, reputation != self.reputation {
            self.reputation = reputation
            changed["reputation"] = reputation.stringValue
        }
        if let photo = data["photo"] as? Photo, photo.isCustomSavedPhoto
            && self.photo?.isCustomSavedPhoto == false && photo != self.photo {
            // only do this if we aren't replacing a custom photo
            // or, if it is a gender change
            self.photo = photo
            changed["photo"] = photo.stringValue
        }
        if !isInternal && !changed.isEmpty {
            hasUnsavedChanges = true
            notifySaveToCloud(fields: changed)
        }
    }

    public mutating func applyRemoteChanges(_ data: [String: Any?]) {
        // not changing: uuid
        // not changing: gameSequenceUuid
        // not changing: gameVersion
        setCommonData(data, isInternal: true)
        // gender
        // appearance?
        // name
        // origin
        // reputation
        classTalent = (data["class"] as? ClassTalent) ?? classTalent
        level = (data["level"] as? Int) ?? level
        paragon = (data["paragon"] as? Int) ?? paragon
        renegade = (data["renegade"] as? Int) ?? renegade
        // photo
        loveInterestId = (data["loveInterestId"] as? String) ?? loveInterestId
    }
    public mutating func applyRemoteChanges(_ data: CodableDictionary) {
        applyRemoteChanges(data.dictionary)
    }
}
//
//// MARK: SerializedDataRetrievable
//extension Shepard: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let uuid = UUID(uuidString: data?["uuid"]?.string ?? ""),
//            let gameSequenceUuid = UUID(uuidString: data?["gameSequenceUuid"]?.string ?? (data?["sequenceUuid"]?.string ?? ""))
//        else {
//            return nil
//        }
//        let gameVersion = GameVersion(stringValue: data?["gameVersion"]?.string ?? "0") ?? .game1
//
//        self.init(
//            uuid: uuid,
//            gameSequenceUuid: gameSequenceUuid,
//            gameVersion: gameVersion,
//            data: data ?? SerializableData()
//        )
//    }
//
//    /// Values general to all shepards should be assigned in setCommonData instead.
//    public mutating func setData(_ data: SerializableData, isInternal: Bool) {
//        // values unique to this GameVersion
//        uuid = UUID(uuidString: data["uuid"]?.string ?? "") ?? uuid
//        gameVersion = GameVersion(stringValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
//        gender = Gender(stringValue: data["gender"]?.string) ?? gender
//        classTalent = ClassTalent(stringValue: data["class"]?.string ?? "") ?? classTalent
//        level = data["level"]?.int ?? level
//        paragon = data["paragon"]?.int ?? paragon
//        renegade = data["renegade"]?.int ?? renegade
//        if let appearanceData = data["appearance"]?.string {
//            appearance = Appearance(appearanceData, fromGame: gameVersion, withGender: gender)
//        }
//        if data["loveInterestId"] != nil {
//            loveInterestId = data["loveInterestId"]?.string // NULLABLE
//        }
//        if let photo = Photo(filePath: data["photo"]?.string) {
//            self.photo = photo
//        } else {
//            photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
//        }
//
////        unserializeDateModifiableData(data: data)
//        gameSequenceUuid = UUID(uuidString: data["gameSequenceUuid"]?.string ?? "") ?? gameSequenceUuid // not GameModifying
////        unserializeLocalCloudData(data: data)
//
//        // commmon values to all shepards in this game sequence:
//        setCommonData(data, isInternal: isInternal)
//    }
//
//    // Protocol adherence - no extra parameters.
//    public mutating func setData(_ data: SerializableData) {
//        setData(data, isInternal: false)
//    }
//}

// MARK: DateModifiable
extension Shepard: DateModifiable {}

// MARK: Equatable
extension Shepard: Equatable {
	public static func == (_ lhs: Shepard, _ rhs: Shepard) -> Bool { // not true equality, just same db row
		return lhs.uuid == rhs.uuid
	}
}

// MARK: Hashable
extension Shepard: Hashable {
	public var hashValue: Int { return uuid.hashValue }
}
// swiftlint:enable file_length
