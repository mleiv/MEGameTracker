//
//  Note.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/19/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

public struct Note: Codable {

    enum CodingKeys: String, CodingKey {
        case uuid
        case gameVersion
        case shepardUuid
        case gameSequenceUuid
        case identifyingObject
        case text
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public internal(set) var uuid: UUID
	public internal(set) var shepardUuid: UUID?
	public internal(set) var identifyingObject: IdentifyingObject

	public private(set) var text: String?

	public var gameVersion: GameVersion

	/// (GameModifying Protocol) 
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

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Note?)>()

// MARK: Initialization
	public init(
        identifyingObject: IdentifyingObject,
        uuid: UUID? = nil,
        shepardUuid: UUID? = nil,
        gameSequenceUuid: UUID? = nil
	) {
		self.uuid = uuid ?? UUID()
		self.shepardUuid = shepardUuid ?? App.current.game?.shepard?.uuid
		self.gameSequenceUuid = gameSequenceUuid ?? App.current.game?.uuid
        self.identifyingObject = identifyingObject
        gameVersion = App.current.gameVersion // TODO: set to gameSequence version when missing
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        gameVersion = try container.decodeIfPresent(GameVersion.self, forKey: .gameVersion)
            ?? App.current.gameVersion // default
        shepardUuid = try container.decodeIfPresent(UUID.self, forKey: .shepardUuid)
            ?? App.current.game?.shepard?.uuid // default
        gameSequenceUuid = try container.decodeIfPresent(UUID.self, forKey: .gameSequenceUuid)
            ?? App.current.game?.uuid // default
        identifyingObject = try container.decode(
            IdentifyingObject.self,
            forKey: .identifyingObject
        )
        text = try container.decodeIfPresent(String.self, forKey: .text)
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(shepardUuid, forKey: .shepardUuid)
        try container.encode(gameSequenceUuid, forKey: .gameSequenceUuid)
        try container.encode(text, forKey: .text)
        try container.encode(identifyingObject, forKey: .identifyingObject)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data

extension Note {
	public static func getDummyNote(json: String? = nil) -> Note? {
		// swiftlint:disable line_length
		let json = json ?? "{\"uuid\":1,\"shepardUuid\":1,\"identifyingObject\":{\"type\":\"Map\",\"id\":1},\"text\":\"A note.\"}"
        return try? defaultManager.decoder.decode(Note.self, from: json.data(using: .utf8)!)
		// swiftlint:enable line_length
	}
}

// MARK: Data Change Actions
extension Note {
	public mutating func change(text: String, isSave: Bool = true, isNotify: Bool = true) {
		if text != self.text {
			self.text = text
			hasUnsavedChanges = true
			markChanged()
			notifySaveToCloud(fields: ["text": text])
			if isSave {
				_ = saveAnyChanges()
			}
			if isNotify {
				Note.onChange.fire((id: self.uuid.uuidString, object: self))
			}
		}
	}
}

// MARK: DateModifiable
extension Note: DateModifiable {}

// MARK: GameModifying
extension Note: GameModifying {}

// MARK: Equatable
extension Note: Equatable {
	public static func == (_ lhs: Note, _ rhs: Note) -> Bool { // not true equality, just same db row
		return lhs.uuid == rhs.uuid
	}
}

// MARK: Hashable
extension Note: Hashable {
	public var hashValue: Int { return uuid.hashValue }
}
