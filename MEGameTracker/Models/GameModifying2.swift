//
//  GameModifying.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/18/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Describes game properties for conforming objects.
public protocol GameModifying2 {

    /// This value's game identifier.
    var gameSequenceUuid: UUID? { get set }

    /// Flag the game as having changed when this value changes.
    func markGameChanged(with manager: CodableCoreDataManageable?)
}
extension GameModifying2 {
    /// (Protocol default)
    /// Flag the game as having changed when this value changes.
    public func markGameChanged(with manager: CodableCoreDataManageable?) {
        guard !App.isInitializing else { return }
let manager2 = CoreDataManager2.current
        // don't trigger onChange event
        App.current.game?.shepard?.touch()
        _ = App.current.game?.shepard?.save(with: manager2)
    }

    /// Convenience version of markGameChanged:manager (no parameters required).
    public func markGameChanged() {
        markGameChanged(with: nil)
    }
}

// MARK: Serializable Utilities
extension GameModifying2 where Self: Codable {
    /// Fetch GameSequence value from a Codable dictionary.
    public mutating func unserializeGameModifyingData(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameModifyingCodingKeys.self)
        gameSequenceUuid = try container.decodeIfPresent(UUID.self, forKey: .gameSequenceUuid)
    }
    /// Store GameSequence value to a Codable dictionary.
    public func serializeGameModifyingData(encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GameModifyingCodingKeys.self)
        try container.encode(gameSequenceUuid, forKey: .gameSequenceUuid)
    }
}

/// Codable keys for objects adhering to DateModifiable
public enum GameModifyingCodingKeys: String, CodingKey {
    case gameSequenceUuid
}

