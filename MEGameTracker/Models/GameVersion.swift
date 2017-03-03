//
//  GameVersion.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/21/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Specifies the different game version options.
public enum GameVersion: String {

    case game1 = "1"
    case game2 = "2"
    case game3 = "3"
    
    /// Returns a list of all possible enum variations.
    public static func list() -> [GameVersion] {
        return [.game1, .game2, .game3]
    }
    
    /// Creates an enum from a string value, if possible.
    public init?(stringValue: String?) {
        self.init(rawValue: stringValue ?? "")
    }
    
    /// Returns the string value of an enum.
    public var stringValue: String {
        return rawValue
    }
    
    /// Returns the heading string value of an enum.
    public var headingValue: String {
        switch self {
        case .game1: return "Game 1"
        case .game2: return "Game 2"
        case .game3: return "Game 3"
        }
    }
    
    /// The index of this game version 0 - 2
    public var index: Int {
        return GameVersion.list().index(of: self) ?? 0
    }
    
    /// The int of this game version 1 - 3
    public var intValue: Int {
        switch self {
        case .game1: return 1
        case .game2: return 2
        case .game3: return 3
        }
    }
    
    /// The max level for shepard in this game version
    public var maxShepardLevel: Int {
        switch self {
        case .game1: return 60
        case .game2: return 30
        case .game3: return 60
        }
    }
}
