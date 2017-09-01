//
//  MapLocationType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Various types of a MapLocationable object. 
/// Provides correct headers and grouping when querying a general set of MapLocation.
public enum MapLocationType: String, Codable {
	case map = "Map"
	case mission = "Mission"
	case item = "Item"

	/// Returns a list of all possible enum variations.
	public static func all() -> [MapLocationType] {
		return [.map, .mission, .item]
	}

	/// Returns the string values of all the enum variations.
	private static let stringValues: [MapLocationType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [MapLocationType: String] = [
		.map: "Maps",
		.mission: "Missions",
		.item: "Items",
	]

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
        self.init(rawValue: stringValue ?? "")
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return rawValue
	}

	/// Creates an enum from a heading string value, if possible.
	public init?(headingValue: String) {
		guard let type = MapLocationType.headingValues
			.filter({ $0.1 == headingValue }).map({ $0.0 }).filter({ $0 != nil }).map({ $0! }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the heading string value of an enum.
	public var headingValue: String {
		return MapLocationType.headingValues[self] ?? "Unknown"
	}

	/// Returns the int value of an enum.
    public var intValue: Int? {
        switch self {
            case .map: return 0
            case .mission: return 1
            case .item: return 2
        }
    }
}
