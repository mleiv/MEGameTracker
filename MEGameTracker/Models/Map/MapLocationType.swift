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
public enum MapLocationType: Int {
	case map = 0
	case mission
	case item

	/// Returns a list of all possible enum variations.
	public static func list() -> [MapLocationType] {
		return [.map, .mission, .item]
	}

	/// Returns the string values of all the enum variations.
	fileprivate static let stringValues: [MapLocationType: String] = [
		.map: "Map",
		.mission: "Mission",
		.item: "Item",
	]

	/// Returns the heading string values of all the enum variations.
	fileprivate static let headingValues: [MapLocationType: String] = [
		.map: "Maps",
		.mission: "Missions",
		.item: "Items",
	]

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String) {
		guard let type = MapLocationType.stringValues
			.filter({ $0.1 == stringValue }).map({ $0.0 }).filter({ $0 != nil }).map({ $0! }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return MapLocationType.stringValues[self] ?? "Unknown"
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
	public var intValue: Int {
		return self.rawValue
	}
}
