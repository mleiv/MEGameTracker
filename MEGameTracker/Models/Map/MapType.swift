//
//  MapType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various map types. Allows for some general logic on sets of maps.
public enum MapType: Int {

	case galaxy = 0
	// regional clusters have no map
	case cluster
	case system
	case planet
	case moon
	case asteroid
	case city
	case ship
	case fleet
	case wreckage
	case area
	case level
	case building
	case location

	/// Returns a list of all possible enum variations.
	public static func list() -> [MapType] {
		return [.galaxy, .cluster, .system, .planet, .asteroid, .city, .ship, .area, .level, .building, .location]
	}

	/// Returns the string values of all the enum variations.
	fileprivate static let stringValues: [MapType: String] = [
		.galaxy: "Galaxy",
		.cluster: "Cluster",
		.system: "System",
		.planet: "Planet",
		.moon: "Moon",
		.asteroid: "Asteroid",
		.city: "City",
		.ship: "Ship",
		.fleet: "Fleet",
		.wreckage: "Wreckage",
		.area: "Area",
		.level: "Level",
		.building: "Structure",
		.location: "Location",
	]

	/// Returns the heading string values of all the enum variations.
	fileprivate static let headingValues: [MapType: String] = [
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
		guard let type = MapType.stringValues
			.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return MapType.stringValues[self] ?? "Unknown"
	}

	/// Creates an enum from a heading string value, if possible.
	public init?(headingValue: String?) {
		guard let type = MapType.headingValues
			.filter({ $0.1 == headingValue }).flatMap({ $0.0 }).first
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
	public var intValue: Int {
		return self.rawValue
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
