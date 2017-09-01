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
public enum EventType: String, Codable {

	case unknown = "Unknown"
	case unavailableInGame = "UnavailableInGame"
	case requiresConfig = "RequiresConfig"
	case blockedUntil = "BlockedUntil"
	case blockedAfter = "BlockedAfter"
	case triggers = "Triggers"

	/// Returns a list of all possible enum variations.
	public static func all() -> [EventType] {
		return [
            .unknown,
            .unavailableInGame,
            .requiresConfig,
            .blockedUntil,
            .blockedAfter,
            .triggers,
        ]
	}

	/// Returns the string values of all the enum variations.
	private static let stringValues: [EventType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		self.init(rawValue: stringValue ?? "")
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
	private static let inheritableEvents: [EventType] = [
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
