//
//  MissionType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various mission types.
public enum MissionType: Int {

    case mission = 0
    case assignment
    case dossier
    case loyalty
    case dlc
    case collection
    case upgrade
    case task
    case objective
    case subset
    
    /// Returns a list of all possible enum variations.
    public static func list() -> [MissionType] {
        return [.mission, .assignment, .dossier, .loyalty, .dlc, .collection, .upgrade, .task, .objective, .subset]
    }
    
    /// Returns a list of all enums to be shown in headings (objective, subset excluded).
    public static func listHeadings() -> [MissionType] {
        return [.mission, .assignment, .dossier, .loyalty, .dlc, .collection, .upgrade, .task]
    }
    
    /// Returns the string values of all the enum variations.
    fileprivate static let stringValues: [MissionType: String] = [
        .mission: "Mission",
        .assignment: "Assignment",
        .dossier: "Dossier",
        .loyalty: "Loyalty",
        .dlc: "DLC",
        .collection: "Collection",
        .upgrade: "Upgrade",
        .task: "Task",
        .objective: "Objective",
        .subset: "Set",
    ]
    
    /// Returns the heading string values of all the enum variations.
    fileprivate static let headingValues: [MissionType: String] = [
        .mission: "Missions",
        .assignment: "Assignments",
        .dossier: "Dossiers",
        .loyalty: "Loyalty",
        .dlc: "DLCs",
        .collection: "Collections",
        .upgrade: "Upgrades",
        .task: "Tasks",
        .subset: "Sets",
    ]
    
    /// Creates an enum from a string value, if possible.
    public init?(stringValue: String?) {
        guard let type = MissionType.stringValues.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first else { return nil }
        self = type
    }
    
    /// Returns the string value of an enum.
    public var stringValue: String {
        return MissionType.stringValues[self] ?? "Unknown"
    }
    
    /// Creates an enum from a heading string value, if possible.
    public init?(headingValue: String?) {
        guard let type = MissionType.headingValues.filter({ $0.1 == headingValue }).flatMap({ $0.0 }).first else { return nil }
        self = type
    }
    
    /// Returns the heading string value of an enum.
    public var headingValue: String {
        return MissionType.headingValues[self] ?? "Unknown"
    }
    
    /// Returns the int value of an enum.
    public var intValue: Int {
        return self.rawValue
    }
    
    /// Provides a title prefix for a mission of the specified enum type.
    public var titlePrefix: String {
        switch self {
        case .mission: return ""
        case .assignment: return ""
        case .collection: return ""
        case .subset: return ""
        default: return "\(stringValue): "
        }
    }
}
