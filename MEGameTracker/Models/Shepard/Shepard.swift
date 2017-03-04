//
//  Shepard.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct Shepard: Photographical {
// MARK: Constants

    public static let DefaultSurname = "Shepard"

// MARK: Properties

    public var id: String { return uuid }
    public internal(set) var uuid = "\(UUID().uuidString)"

    /// (GameModifying Protocol) 
    /// This value's game identifier.
    public var gameSequenceUuid: String
    
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
    public var pendingCloudChanges: SerializableData?
    /// (CloudDataStorable Protocol)  
    /// A copy of the last cloud kit record.
    public var lastRecordData: Data?
    
    public fileprivate(set) var gameVersion: GameVersion
    
    public fileprivate(set) var gender = Gender.male
    public fileprivate(set) var name = Name.defaultMaleName
    public fileprivate(set) var photo: Photo?
    public fileprivate(set) var appearance: Appearance
    public fileprivate(set) var origin = Origin.earthborn
    public fileprivate(set) var reputation = Reputation.soleSurvivor
    public fileprivate(set) var classTalent = ClassTalent.soldier
    public fileprivate(set) var loveInterestId: String?
    public fileprivate(set) var level: Int = 1
    public fileprivate(set) var paragon: Int = 0
    public fileprivate(set) var renegade: Int = 0
    
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
    public static func getPhotoFileNameIdentifier(uuid: String) -> String {
        return "MyShepardPhoto\(uuid)"
    }
    
// MARK: Change Listeners And Change Status Flags
    
    public var isNew: Bool = false
    
    /// (DateModifiable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
    /// Don't use this. Use App.onCurrentShepardChange instead.
    public static let onChange = Signal<(id: String, object: Shepard)>()
    
// MARK: Initialization
    
    /// Created by App
    public init(gameSequenceUuid: String, gender: Shepard.Gender = .male, gameVersion: GameVersion = .game1) {
        self.gameSequenceUuid = gameSequenceUuid
        self.gender = gender
        self.gameVersion = gameVersion
        appearance = Appearance(gameVersion: gameVersion)
        photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
        markChanged()
    }
    
    /// Created by CloudKit or SerializableData
    public init(uuid: String, gameSequenceUuid: String, gameVersion: GameVersion = .game1, data: SerializableData? = nil) {
        self.uuid = uuid
        self.gameSequenceUuid = gameSequenceUuid
        self.gameVersion = gameVersion
        appearance = Appearance(gameVersion: gameVersion)
        if let data = data {
            setData(data, isInternal: true)
        } else {
            photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
        }
    }
    
    /// Called by app when creating a new gameVersion of an existing shepard - copy over all the general shared choices.
    public mutating func setNewData(oldData: SerializableData, oldGame: GameVersion?) {
        setCommonData(oldData)
        // only do when converting to a new game version:
        if let oldGame = oldGame {
            var appearance = Appearance(oldData["appearance"]?.string ?? "", fromGame: oldGame, withGender: gender)
            appearance.convert(toGame: gameVersion)
            self.appearance = appearance
            classTalent = ClassTalent(stringValue: oldData["class"]?.string ?? "") ?? classTalent
            if let photo = Photo(filePath: oldData["photo"]?.string) {
                self.photo = photo
            }
        }
    }
    
    public mutating func setCommonData(_ data: SerializableData, isInternal: Bool = false) {
        // make sure to notify these changes to cloud
        var changed: [String: SerializableData?] = [:]
        if let gender = Gender(stringValue: data["gender"]?.string),
            gender != self.gender {
            self.gender = gender
            changed["gender"] = gender.stringValue.getData()
        }
        if let name = data["name"]?.string,
            name != self.name.stringValue {
            self.name = Name(name: name, gender: gender) ?? self.name
            changed["name"] = name.getData()
        }
        if let origin = Origin(stringValue: data["origin"]?.string ?? ""),
            origin != self.origin {
            self.origin = origin
            changed["origin"] = origin.stringValue.getData()
        }
        if let reputation = Reputation(stringValue: data["reputation"]?.string ?? ""),
            reputation != self.reputation {
            self.reputation = reputation
            changed["reputation"] = reputation.stringValue.getData()
        }
        if let photo = Photo(filePath: data["photo"]?.string),
            photo.isCustomSavedPhoto
            && self.photo?.isCustomSavedPhoto == false
            && photo != self.photo {
            // only do this if we aren't replacing a custom photo
            // or, if it is a gender change
            self.photo = photo
            changed["photo"] = photo.stringValue.getData()
        }
        if !isInternal && !changed.isEmpty {
            hasUnsavedChanges = true
            notifySaveToCloud(fields: changed)
        }
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
    public func getNotes(completion: @escaping (([Note])->Void) = { _ in }) {
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
                Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
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
            Shepard.onChange.fire((id: uuid, object: self))
        }
    }
    
}

// MARK: Dummy data for Interface Builder
extension Shepard {
    public static func getDummy(json: String? = nil) -> Shepard? {
        let json = json ?? "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"
        var game = GameSequence()
        if let data = try? SerializableData(serializedString: json) {
            game.shepard?.setData(data)
        }
        return game.shepard
    }
}

// MARK: SerializedDataStorable
extension Shepard: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["uuid"] = uuid
        list["gameVersion"] = gameVersion.stringValue
        list["level"] = level
        list["paragon"] = paragon
        list["renegade"] = renegade
        list["gender"] = gender.stringValue
        list["name"] = name.stringValue
        list["appearance"] = appearance.format()
        list["photo"] = photo?.isCustomSavedPhoto == true ? photo?.stringValue : nil
        list["origin"] = origin.stringValue
        list["reputation"] = reputation.stringValue
        list["class"] = classTalent.stringValue
        list["loveInterestId"] = loveInterestId
        list = serializeDateModifiableData(list: list)
        list["gameSequenceUuid"] = gameSequenceUuid // not GameModifying
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Shepard: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let uuid = data?["uuid"]?.string,
            let gameSequenceUuid = data?["gameSequenceUuid"]?.string ?? data?["sequenceUuid"]?.string,
            gameSequenceUuid.isEmpty == false
        else {
            return nil
        }
        let gameVersion = GameVersion(stringValue: data?["gameVersion"]?.string ?? "0") ?? .game1
        
        self.init(uuid: uuid, gameSequenceUuid: gameSequenceUuid, gameVersion: gameVersion, data: data ?? SerializableData())
    }
    
    /// Values general to all shepards should be assigned in setCommonData instead.
    public mutating func setData(_ data: SerializableData, isInternal: Bool) {
        // values unique to this GameVersion
        uuid = data["uuid"]?.string ?? uuid
        gameVersion = GameVersion(stringValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
        gender = Gender(stringValue: data["gender"]?.string) ?? gender
        classTalent = ClassTalent(stringValue: data["class"]?.string ?? "") ?? classTalent
        level = data["level"]?.int ?? level
        paragon = data["paragon"]?.int ?? paragon
        renegade = data["renegade"]?.int ?? renegade
        if let appearanceData = data["appearance"]?.string {
            appearance = Appearance(appearanceData, fromGame: gameVersion, withGender: gender)
        }
        if data["loveInterestId"] != nil {
            loveInterestId = data["loveInterestId"]?.string // NULLABLE
        }
        if let photo = Photo(filePath: data["photo"]?.string) {
            self.photo = photo
        } else {
            photo = Photo(filePath: Shepard.PhotoPath.defaultPath(forGender: gender, forGameVersion: gameVersion))
        }
        
        unserializeDateModifiableData(data: data)
        gameSequenceUuid = data["gameSequenceUuid"]?.string ?? gameSequenceUuid // not GameModifying
        unserializeLocalCloudData(data: data)
        
        // commmon values to all shepards in this game sequence:
        setCommonData(data, isInternal: isInternal)
    }
    
    // Protocol adherence - no extra parameters.
    public mutating func setData(_ data: SerializableData) {
        setData(data, isInternal: false)
    }
}

//MARK: DateModifiable
extension Shepard: DateModifiable {}

//MARK: Equatable
extension Shepard: Equatable {
    public static func ==(a: Shepard, b: Shepard) -> Bool { // not true equality, just same db row
        return a.uuid == b.uuid
    }
}

// MARK: Hashable
extension Shepard: Hashable {
    public var hashValue: Int { return uuid.hashValue }
}


