//
//  CurrentGame.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/9/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

public struct GameSequence: Codable {

    enum CodingKeys: String, CodingKey {
        case uuid
        case lastPlayedShepard
    }

// MARK: Constants
	public typealias ShepardVersionIdentifier = (uuid: String, gameVersion: GameVersion)

// MARK: Properties
	public var id: UUID { return uuid }
	public var uuid: UUID
	public var shepard: Shepard?

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

	/// (Interface Builder) (Transient)
	public var isDummyData = false

// MARK: Computed Properties

	public var gameVersion: GameVersion {
		return shepard?.gameVersion ?? .game1
	}

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable Protocol) (Transient)
	/// Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false

// MARK: Initialization

	public init(uuid: UUID? = nil) {
		self.uuid = uuid ?? UUID()
		let shepard = Shepard(gameSequenceUuid: self.uuid, gameVersion: .game1)
		self.shepard = shepard
		markChanged()
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)

        if let lastPlayedShepard = try container.decodeIfPresent(UUID.self, forKey: .lastPlayedShepard),
            lastPlayedShepard != self.shepard?.uuid,
            let shepard = Shepard.get(uuid: lastPlayedShepard) {
            self.shepard = shepard
        } else {
            // you only reach this if there was an error saving shepard last game save.
            self.shepard = Shepard.lastPlayed(gameSequenceUuid: uuid)
                  ?? Shepard(gameSequenceUuid: self.uuid, gameVersion: .game1)
            markChanged()
        }

        try unserializeDateModifiableData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(shepard?.uuid, forKey: .lastPlayedShepard)
        try serializeDateModifiableData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension GameSequence {

	public func getAllShepards() -> [Shepard] {
		return Shepard.getAll(gameSequenceUuid: uuid)
	}

}

// MARK: Data Change Actions
extension GameSequence {

	/// Changes current shepard to a different game version shepard, creating that shepard if necessary.
	/// Warning: due to App static current shepard signal, DO NOT call this directly.
	internal mutating func change(gameVersion newGameVersion: GameVersion) {
		guard newGameVersion != gameVersion else { return }
		// save prior shepard
		_ = shepard?.saveAnyChanges(isCascadeChanges: .down, isAllowDelay: false)
		// locate different gameVersion shepard
		guard var shepard = getShepardFromVersion(newGameVersion) else { return }
		// save if new
		if shepard.isNew {
			shepard.isNew = false
			addNewShepardVersion(shepard)
		}
		self.shepard = shepard
		markChanged()
		// save current game and shepard (to mark most recent)
		_ = save(isAllowDelay: false)
	}

	/// Used to change game version OR to load a shepard to test conditions against (see: Decision)
	public func getShepardFromVersion(_ newGameVersion: GameVersion) -> Shepard? {
		guard newGameVersion != gameVersion else { return nil }
		// locate new shepard
		if let foundShepard = Shepard.get(gameVersion: newGameVersion, gameSequenceUuid: uuid) {
			return foundShepard
		} else {
			let gender = shepard?.gender ?? .male
			var newShepard = Shepard(gameSequenceUuid: uuid, gender: gender, gameVersion: newGameVersion)
			// share all data from other game version:
			if let shepard = self.shepard {
				newShepard.setNewData(oldData: shepard.getSharedData())
			}
			newShepard.isNew = true
			return newShepard
		}
	}

	private mutating func addNewShepardVersion(_ shepard: Shepard) {
		var shepard = shepard
		shepard.gameSequenceUuid = uuid
		_ = shepard.saveAnyChanges(isCascadeChanges: .down) //isAllowDelay = true
//		markChanged()
//		_ = saveAnyChanges() // this is called later in GameSequence change(gameVersion:)
	}
}

// MARK: Dummy data for Interface Builder
extension GameSequence {
	public static func getDummy() -> GameSequence? {
		var game = GameSequence()
		game.isDummyData = true
		game.shepard = Shepard.getDummy()
		game.shepard?.gameSequenceUuid = game.uuid
		return game
	}
}

// MARK: Shared Data
extension GameSequence {
    public mutating func applyRemoteChanges(_ data: [String: Any?]) {
        // not changing: uuid
        if let shepardUuidString = data["lastPlayedShepard"] as? String,
           let shepardUuid = UUID(uuidString: shepardUuidString) {
            shepard = Shepard(gameSequenceUuid: uuid, uuid: shepardUuid)
            // dummy copy, just to keep ref to shepardUuid
            // TODO: maybe extract behavior to parameter - too specific to cloud sync?
        }
        unserializeDateModifiableData(data)
    }
    public mutating func applyRemoteChanges(_ data: CodableDictionary) {
        applyRemoteChanges(data.dictionary)
    }
}

// MARK: DateModifiable
extension GameSequence: DateModifiable {

	public mutating func markChanged() {
		touch()
		notifySaveToCloud(fields: ["lastPlayedShepard": shepard?.uuid ?? ""])
		hasUnsavedChanges = true
	}
}

// MARK: Sorting
extension GameSequence {

	static func sort(_ first: GameSequence, _ second: GameSequence) -> Bool {
		return (first.shepard?.modifiedDate ?? Date())
			.compare(second.shepard?.modifiedDate ?? Date()) == .orderedDescending
	}
}

// MARK: Equatable
extension GameSequence: Equatable {
	public static func == (_ lhs: GameSequence, _ rhs: GameSequence) -> Bool { // not true equality, just same db row
		return lhs.uuid == rhs.uuid
	}
}

// MARK: Hashable
extension GameSequence: Hashable {
	public var hashValue: Int { return uuid.hashValue }
}
