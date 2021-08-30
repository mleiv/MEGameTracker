//
//  Shepard.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

public struct Shepard: Codable, Photographical, PhotoEditable {

    enum CodingKeys: String, CodingKey {
        case uuid
        case gameSequenceUuid
        case gameVersion
        case gender
        case appearance
        case name
        case duplicationCount
        case origin
        case reputation
        case classTalent = "class"
        case isLegendary
        case level
        case paragon
        case renegade
        case photo
        case loveInterestId
    }

// MARK: Constants
	public static let DefaultSurname = "Shepard"

// MARK: Properties
    public var rawData: Data? // transient
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

    public private(set) var duplicationCount = 1

	public private(set) var gender = Gender.male
	public private(set) var name = Name.defaultMaleName
	public private(set) var photo: Photo?
	public private(set) var appearance: Appearance
	public private(set) var origin = Origin.earthborn
	public private(set) var reputation = Reputation.soleSurvivor
	public private(set) var classTalent = ClassTalent.soldier
    public private(set) var isLegendary = false
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
    public var fullName: String { return "\(name.stringValue!) Shepard" + (duplicationCount > 1 ? " \(duplicationCount)" : "") }
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
	public init(
        gameSequenceUuid: UUID,
        uuid: UUID = UUID(),
        gender: Shepard.Gender = .male,
        gameVersion: GameVersion = .game1
    ) {
        self.uuid = uuid
		self.gameSequenceUuid = gameSequenceUuid
		self.gender = gender
		self.gameVersion = gameVersion
        appearance = Appearance(gameVersion: Shepard.Appearance.gameVersion(isLegendary: isLegendary, gameVersion: gameVersion))
		photo = DefaultPhoto(gender: .male, gameVersion: gameVersion).photo
		markChanged()
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        gameSequenceUuid = try container.decode(UUID.self, forKey: .gameSequenceUuid)
        gameVersion = try container.decode(GameVersion.self, forKey: .gameVersion)
        gender = try container.decode(Shepard.Gender.self, forKey: .gender)
        isLegendary = try container.decodeIfPresent(Bool.self, forKey: .isLegendary) ?? false
        let appearanceGameVersion = Shepard.Appearance.gameVersion(isLegendary: isLegendary, gameVersion: gameVersion)
        if let appearanceString = try container.decodeIfPresent(String.self, forKey: .appearance) {
            appearance = Appearance(appearanceString, fromGame: appearanceGameVersion, withGender: gender)
        } else {
            appearance = Appearance(gameVersion: appearanceGameVersion)
        }
        let nameString = try container.decode(String.self, forKey: .name)
        name = Shepard.Name(name: nameString, gender: gender) ?? name
        duplicationCount = try container.decodeIfPresent(Int.self, forKey: .duplicationCount) ?? duplicationCount
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
            photo = DefaultPhoto(gender: gender, gameVersion: gameVersion).photo
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
        try container.encode(duplicationCount, forKey: .duplicationCount)
        try container.encode(origin, forKey: .origin)
        try container.encode(reputation, forKey: .reputation)
        try container.encode(classTalent, forKey: .classTalent)
        try container.encode(isLegendary, forKey: .isLegendary)
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
}

// MARK: Data Change Actions
extension Shepard {

	/// **Warning**: this changes a lot of data and takes a long time
    /// Return a copy of this Shepard with gender changed
    public func changed(
        gender: Gender,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard gender != self.gender else { return self }
        var shepard = self
        shepard.gender = gender
        var cloudChanges: [String: Any?] = ["gender": gender == .male ? "M" : "F"]
        let gameVersion: GameVersion = shepard.gameVersion
        let loveInterest: Person? = shepard.getLoveInterest()
        switch gender {
        case .male:
            if shepard.name == .defaultFemaleName {
                shepard.name = .defaultMaleName
                cloudChanges["name"] = name.stringValue
            }
            if shepard.photo?.isCustomSavedPhoto != true {
                shepard.photo = DefaultPhoto(gender: gender, gameVersion: gameVersion).photo
                cloudChanges["photo"] = photo?.stringValue
            }
            shepard.appearance.gender = gender
            cloudChanges["appearance"] = shepard.appearance.format()
            if loveInterest?.isMaleLoveInterest != true {
                // pass to love interest method to handle other side effects
                shepard = shepard.changed(loveInterestId: nil, isSave: false, isNotify: false)
                cloudChanges["loveInterestId"] = nil
            }
        case .female:
            if shepard.name == .defaultMaleName {
                shepard.name = .defaultFemaleName
                cloudChanges["name"] = name.stringValue
            }
            if shepard.photo?.isCustomSavedPhoto != true {
                shepard.photo = DefaultPhoto(gender: gender, gameVersion: gameVersion).photo
                cloudChanges["photo"] = photo?.stringValue
            }
            shepard.appearance.gender = gender
            cloudChanges["appearance"] = shepard.appearance.format()
            if loveInterest?.isFemaleLoveInterest != true {
                // pass to love interest method to handle other side effects
                shepard = shepard.changed(loveInterestId: nil, isSave: false, isNotify: false)
                cloudChanges["loveInterestId"] = nil
            }
        }

        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: cloudChanges
        )
        return shepard
    }

    /// Return a copy of this Shepard with name changed
    public func changed(
        name: String?,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard name != self.name.stringValue else { return self }
        var shepard = self
        shepard.name = Name(name: name, gender: gender) ?? self.name
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["name": name]
        )
        return shepard
    }

    /// PhotoEditable Protocol
    /// Return a copy of this Shepard with photo changed
    public func changed(photo: Photo) -> Shepard {
        return changed(photo: photo, isSave: true)
    }
    /// Return a copy of this Shepard with photo changed
    public func changed(photo: Photo, isSave: Bool) -> Shepard {
        return changed(photo: photo, isSave: isSave, isNotify: true)
    }
    /// Return a copy of this Shepard with photo changed
    public func changed(
        photo: Photo,
        isSave: Bool,
        isNotify: Bool
    ) -> Shepard {
        guard photo != self.photo else { return self }
        var shepard = self
        // We use old filename, so don't delete
        shepard.photo = photo
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["photo": photo.stringValue]
        )
        return shepard
    }

    /// Return a copy of this Shepard with appearance changed
    public func changed(
        appearance: Appearance,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard appearance != self.appearance else { return self }
        var shepard = self
        shepard.appearance = appearance
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["appearance": appearance.format()]
        )
        return shepard
    }

    /// Return a copy of this Shepard with origin changed
    public func changed(
        origin: Origin,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard origin != self.origin else { return self }
        var shepard = self
        shepard.origin = origin
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["origin": origin.stringValue]
        )
        return shepard
    }

    /// Return a copy of this Shepard with reputation changed
    public func changed(
        reputation: Reputation,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard reputation != self.reputation else { return self }
        var shepard = self
        shepard.reputation = reputation
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["reputation": reputation.stringValue]
        )
        return shepard
    }

    /// Return a copy of this Shepard with classTalent changed
    public func changed(
        class classTalent: ClassTalent,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard classTalent != self.classTalent else { return self }
        var shepard = self
        shepard.classTalent = classTalent
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["class": classTalent.stringValue]
        )
        return shepard
    }
    
    /// Return a copy of this Shepard with isLegendary changed
    public func changed(
        isLegendary: Bool,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard isLegendary != self.isLegendary else { return self }
        var shepard = self
        shepard.isLegendary = isLegendary
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["isLegendary": isLegendary]
        )
        return shepard
    }

    /// Return a copy of this Shepard with loveInterestId changed
    public func changed(
        loveInterestId: String?,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) -> Shepard {
        guard loveInterestId != self.loveInterestId else { return self }
        var shepard = self
        // cascade change to decision
        if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
            if let loveInterestId = loveInterestId,
                let person = Person.get(id: loveInterestId),
                let decisionId = person.loveInterestDecisionId {
                // switch selected love interest
                _ = Decision.get(id: decisionId)?.changed(
                    isSelected: true,
                    isSave: isSave,
                    isNotify: isNotify,
                    isCascadeChanges: .none
                )
            } else if loveInterestId == nil,
                let loveInterestId = self.loveInterestId,
                let person = Person.get(id: loveInterestId),
                let decisionId = person.loveInterestDecisionId {
                // erase unselected love interest
                _ = Decision.get(id: decisionId)?.changed(
                    isSelected: false,
                    isSave: isSave,
                    isNotify: isNotify,
                    isCascadeChanges: .none
                )
            }
        }
        shepard.loveInterestId = loveInterestId
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["loveInterestId": loveInterestId]
        )
        return shepard
    }

    /// Return a copy of this Shepard with level changed
    public func changed(
        level: Int,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard level != self.level else { return self }
        var shepard = self
        shepard.level = level
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["level": level]
        )
        return shepard
    }

    /// Return a copy of this Shepard with paragon changed
    public func changed(
        paragon: Int,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard paragon != self.paragon else { return self }
        var shepard = self
        shepard.paragon = paragon
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["paragon": paragon]
        )
        return shepard
    }

    /// Return a copy of this Shepard with renegade changed
    public func changed(
        renegade: Int,
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        guard renegade != self.renegade else { return self }
        var shepard = self
        shepard.renegade = renegade
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["renegade": renegade]
        )
        return shepard
    }

    /// Return a copy of this Shepard with duplicationCount changed
    public func incrementDuplicationCount(
        isSave: Bool = true,
        isNotify: Bool = true
    ) -> Shepard {
        var shepard = self
        shepard.duplicationCount = duplicationCount + 1
        shepard.changeEffects(
            isSave: isSave,
            isNotify: isNotify
        )
        return shepard
    }

    /// Performs common behaviors after an object change
    private mutating func changeEffects(
        isSave: Bool = true,
        isNotify: Bool = true,
        cloudChanges: [String: Any?] = [:]
    ) {
        markChanged()
        notifySaveToCloud(fields: cloudChanges)
        if isSave {
            _ = saveAnyChanges(isAllowDelay: false)
        }
        if isNotify {
            Shepard.onChange.fire((id: uuid.uuidString, object: self))
        }
    }

    mutating func restart(uuid: UUID, gameSequenceUuid: UUID) {
        self.uuid = uuid
        self.gameSequenceUuid = gameSequenceUuid
        loveInterestId = nil
        level = 0
        paragon = 0
        renegade = 0
        rawData = nil
        hasUnsavedChanges = true
    }
}

// MARK: Dummy data for Interface Builder
extension Shepard {
	public static func getDummy(json: String? = nil) -> Shepard? {
		// swiftlint:disable line_length
		let json = json ?? "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"
		// swiftlint:enable line_length
		return try? defaultManager.decoder.decode(Shepard.self, from: json.data(using: .utf8)!)
	}
}

// MARK: Shared Data
extension Shepard {
    public func getSharedData() -> [String: Any?] {
        var list: [String: Any?] = [:]
        list["gameVersion"] = gameVersion
        list["gender"] = gender
        list["name"] = name
        list["duplicationCount"] = duplicationCount
        list["origin"] = origin
        list["reputation"] = reputation
        list["class"] = classTalent
        list["isLegendary"] = isLegendary
        list["appearance"] = appearance
        list["photo"] = photo?.isCustomSavedPhoto == true ? photo : nil
        return list
    }

    /// Called by app when creating a new gameVersion of an existing shepard - copy over all the general shared choices.
    public mutating func setNewData(oldData: [String: Any?]) {
        setCommonData(oldData)
        // only do when converting to a new game version:
        if var oldAppearance = oldData["appearance"] as? Appearance {
            let appearanceGameVersion = Shepard.Appearance.gameVersion(isLegendary: isLegendary, gameVersion: gameVersion)
            oldAppearance.convert(toGame: appearanceGameVersion) // TODO: immutable chained convert
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
        if let duplicationCount = data["duplicationCount"] as? Int, duplicationCount != self.duplicationCount {
            self.duplicationCount = duplicationCount
            changed["duplicationCount"] = duplicationCount
        }
        if let origin = data["origin"] as? Origin, origin != self.origin {
            self.origin = origin
            changed["origin"] = origin.stringValue
        }
        if let reputation = data["reputation"] as? Reputation, reputation != self.reputation {
            self.reputation = reputation
            changed["reputation"] = reputation.stringValue
        }
        if let isLegendary = data["isLegendary"] as? Bool, isLegendary != self.isLegendary {
            self.isLegendary = isLegendary
            changed["isLegendary"] = isLegendary
        }
        if let photo = data["photo"] as? Photo, photo.isCustomSavedPhoto
            && self.photo?.isCustomSavedPhoto == false && photo != self.photo {
            // only do this if we aren't replacing a custom photo
            // or, if it is a gender change
            self.photo = photo
            changed["photo"] = photo.stringValue
        }
        if !isInternal && !changed.isEmpty {
            markChanged()
            notifySaveToCloud(fields: changed)
        }
    }
}

// MARK: DateModifiable
extension Shepard: DateModifiable {}

// MARK: Equatable
extension Shepard: Equatable {
	public static func == (_ lhs: Shepard, _ rhs: Shepard) -> Bool { // not true equality, just same db row
		return lhs.uuid == rhs.uuid
	}
}

//// MARK: Hashable
//extension Shepard: Hashable {
//    public var hashValue: Int { return uuid.hashValue }
//}
// swiftlint:enable file_length
