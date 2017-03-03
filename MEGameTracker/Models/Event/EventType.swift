//
//  EventType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Event types are defined in the target object using the event rather than in an event object itself.
/// Example: the event of "Unlocked Galaxy Map" is flagged in blockedUntil in the mission A1.C1.AsariConsort.
public enum EventType {

    case unknown
    case unavailableInGame
    case requiresConfig
    case blockedUntil
    case blockedAfter
    case triggers

    /// Returns a list of all possible enum variations.
    public static func list() -> [EventType] {
        return [.unknown, .unavailableInGame, .requiresConfig, .blockedUntil, .blockedAfter, .triggers]
    }
    
    /// Returns the string values of all the enum variations.
    fileprivate static let stringValues: [EventType: String] = [
        .unknown: "Unknown",
        .unavailableInGame: "UnavailableInGame",
        .requiresConfig: "RequiresConfig",
        .blockedUntil: "BlockedUntil",
        .blockedAfter: "BlockedAfter",
        .triggers: "Triggers",
    ]
    
    
    /// Creates an enum from a string value, if possible.
    public init?(stringValue: String?) {
        guard let type = EventType.stringValues.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first else { return nil }
        self = type
    }
    
    /// Returns the string value of an enum.
    public var stringValue: String {
        return EventType.stringValues[self] ?? "Unknown"
    }
    
    /// Provides a description prefix for an event of the specified enum type.
    public var eventDescriptionPrefix: String? {
        switch self {
        case .blockedUntil: return "Prerequisite: "
        case .blockedAfter: return "Unavailable after: "
        case .unavailableInGame: return "Unavailable in "
        case .requiresConfig: return "Requires "
        default: return nil
        }
    }
    
    
    /// Returns a subset of events which have cascading effects.
    /// This is useful during core data import, so we can cascade the values and save ourselves lookup work later.   
    fileprivate static let inheritableEvents: [EventType] = [
        .blockedUntil,
        .blockedAfter,
        .unavailableInGame,
        .requiresConfig,
    ]
    
    /// Determines if this type is inheritable.
    public var isAppliesToChildren: Bool {
        return EventType.inheritableEvents.contains(self)
    }
}
