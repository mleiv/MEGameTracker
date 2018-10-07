//
//  MapType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various map types. Allows for some general logic on sets of maps.
public enum MapType: String, Codable {

	case galaxy = "Galaxy"
	// regional clusters have no map
	case cluster = "Cluster"
	case system = "System"
	case planet = "Planet"
	case moon = "Moon"
	case asteroid = "Asteroid"
	case city = "City"
	case ship = "Ship"
	case fleet = "Fleet"
	case wreckage = "Wreckage"
	case area = "Area"
	case level = "Level"
	case building = "Structure"
	case location = "Location"

	/// Returns a list of all possible enum variations.
	public static func all() -> [MapType] {
		return [
            .galaxy,
            .cluster,
            .system,
            .planet,
            .moon,
            .asteroid,
            .city,
            .ship,
            .fleet,
            .area,
            .level,
            .building,
            .location
        ]
	}

	/// Returns the string values of all the enum variations.
	private static let stringValues: [MapType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [MapType: String] = [
		.galaxy: "Galaxies",
		.cluster: "Clusters",
		.system: "Systems",
		.planet: "Planets",
		.moon: "Moons",
		.city: "Cities",
		.ship: "Ships",
		.fleet: "Fleets",
		.wreckage: "Wreckage",
		.area: "Areas",
		.level: "Levels",
		.building: "Structures",
		.location: "Locations",
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
	public init?(headingValue: String?) {
		guard let type = MapType.headingValues
			.filter({ $0.1 == headingValue }).map({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the heading string value of an enum.
	public var headingValue: String {
		return MapType.headingValues[self] ?? "Unknown"
	}

	/// Returns the int value of an enum.
	public var intValue: Int? {
		return MapType.all().index(of: self)
	}

	/// Provides a window title for a map of the specified enum type.
	public var windowTitle: String {
		if self == .location {
			return "Map"
		}
		return stringValue
	}

	/// Makes general decision about whether to offer the explorable checkbox for a map of this type.
	public var isExplorable: Bool {
		switch self {
		case .galaxy: fallthrough
		case .cluster: fallthrough
		case .system: return true
		default: return false
		}
	}
}
