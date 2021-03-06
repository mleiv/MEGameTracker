//
//  ItemType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Defines various item types. Some are only available in one game.
public enum ItemType: String, Codable, CaseIterable {
    
    case loot = "Loot"
    case weapon = "Weapon"
    case armor = "Armor"
    case upgrade = "Upgrade"
    case mod = "Mod"
    case ammo = "Ammo"
    case medkit = "MedKit"
    case intel = "Intel"
    case scan = "Scan"// game 3
    case artifact = "Artifact"
    case collection = "Collection"
    case salvage = "Salvage"
    case wreckage = "Wreckage"
    case warAsset = "War Asset"
    case souvenir = "Souvenir"
    case request = "Request"
    case pet = "Pet"
    case model = "Model"
    case data = "Data"
	case unknown = "Unknown"

	/// Returns the string values of all the enum variations.
	private static let stringValues: [ItemType: String] = {
        return Dictionary(uniqueKeysWithValues: allCases.map { ($0, $0.stringValue) })
    }()

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [ItemType: String] = [
        .loot: "Loot",
        .weapon: "Weapons",
        .armor: "Armor",
        .upgrade: "Upgrades",
        .mod: "Mods",
        .ammo: "Ammo",
        .medkit: "MedKits",
        .intel: "Intel",
        .scan: "Scans",
        .artifact: "Artifacts",
        .collection: "Collections",
        .salvage: "Salvage",
        .wreckage: "Wreckage",
        .warAsset: "War Assets",
        .souvenir: "Souvenirs",
        .request: "Requests",
        .pet: "Pets",
        .model: "Models",
        .data: "Data",
        .unknown: "Unknown"
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
        case .loot: fallthrough
		case .medkit: fallthrough
		case .ammo: fallthrough
		case .collection: fallthrough
        case .data: fallthrough
		case .unknown: return ""
		default: return "\(stringValue): "
		}
	}
}
