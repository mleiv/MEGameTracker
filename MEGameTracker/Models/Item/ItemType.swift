//
//  ItemType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Defines various item types. Some are only available in one game.
public enum ItemType {

    case unknown
    case souvenir
    case pet
    case weapon
    case ammo
    case armor
    case medkit
    case loot
    case scan // game 3
    case artifact
    case collection
    case salvage
    case wreckage
    case warAsset
    case intel 
    case upgrade
    
    /// Returns a list of all possible enum variations.
    public static func list() -> [ItemType] {
        return [.weapon, .armor, .upgrade, .loot, .ammo, .medkit,.intel, .scan, .artifact, .collection, .salvage, .wreckage, .warAsset, .souvenir, .pet, .unknown]
    }
    
    /// Returns the string values of all the enum variations.
    fileprivate static let stringValues: [ItemType: String] = [
        .unknown: "Unknown",
        .souvenir: "Souvenir",
        .pet: "Pet",
        .weapon: "Weapon",
        .ammo: "Ammo",
        .armor: "Armor",
        .medkit: "MedKit",
        .loot: "Loot",
        .scan: "Scan",
        .artifact: "Artifact",
        .collection: "Collection",
        .salvage: "Salvage",
        .wreckage: "Wreckage",
        .warAsset: "War Asset",
        .intel: "Intel",
        .upgrade: "Upgrade",
    ]
    
    /// Returns the heading string values of all the enum variations.
    fileprivate static let headingValues: [ItemType: String] = [
        .unknown: "Unknown",
        .souvenir: "Souvenirs",
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
        guard let type = ItemType.stringValues.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first else { return nil }
        self = type
    }
    
    /// Returns the string value of an enum.
    public var stringValue: String {
        return ItemType.stringValues[self] ?? "Unknown"
    }
    
    /// Creates an enum from a heading string value, if possible.
    public init?(headingValue: String?) {
        guard let type = ItemType.headingValues.filter({ $0.1 == headingValue }).flatMap({ $0.0 }).first else { return nil }
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
