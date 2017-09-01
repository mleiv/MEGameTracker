//
//  ItemType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Defines various item types. Some are only available in one game.
public enum ItemType: String, Codable {

	case unknown = "Unknown"
	case souvenir = "Souvenir"
	case request = "Request"
	case pet = "Pet"
	case weapon = "Weapon"
	case ammo = "Ammo"
	case armor = "Armor"
	case medkit = "MedKit"
	case loot = "Loot"
	case scan = "Scan"// game 3
	case artifact = "Artifact"
	case collection = "Collection"
	case salvage = "Salvage"
	case wreckage = "Wreckage"
	case warAsset = "War Asset"
	case intel = "Intel"
	case upgrade = "Upgrade"

	/// Returns a list of all possible enum variations.
	public static func all() -> [ItemType] {
		return [
			.weapon,
			.armor,
			.upgrade,
			.loot,
			.ammo,
			.medkit,
			.intel,
			.scan,
			.artifact,
			.collection,
			.salvage,
			.wreckage,
			.warAsset,
			.souvenir,
			.request,
			.pet,
			.unknown,
		]
	}

	/// Returns the string values of all the enum variations.
	private static let stringValues: [ItemType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [ItemType: String] = [
		.unknown: "Unknown",
		.souvenir: "Souvenirs",
		.request: "Requests",
		.pet: "Pets",
		.weapon: "Weapons",
		.ammo: "Ammo",
		.armor: "Armor",
		.medkit: "MedKits",
		.loot: "Loot",
		.scan: "Scans",
		.artifact: "Artifacts",
		.collection: "Collections",
		.salvage: "Salvage",
		.wreckage: "Wreckage",
		.warAsset: "War Assets",
		.intel: "Intel",
		.upgrade: "Upgrades",
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
		guard let type = ItemType.headingValues
			.filter({ $0.1 == headingValue })
			.map({ $0.0 })
            .filter({ $0 != nil }).map({ $0! })
            .first
		else {
			return nil
		}
		self = type
	}

	/// Returns the heading string value of an enum.
	public var headingValue: String {
		return ItemType.headingValues[self] ?? "Unknown"
	}

	/// Provides a title prefix for an item of the specified enum type.
	public var titlePrefix: String {
		switch self {
		case .medkit: fallthrough
		case .ammo: fallthrough
		case .collection: fallthrough
		case .unknown: return ""
		default: return "\(stringValue): "
		}
	}
}
