//
//  ActionTargetObject.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// Types of objects available for event actions to target.
public enum ActionTargetObject {

    case decision, item, mission
    
    /// Returns a list of all possible enum variations.
    public static func list() -> [ActionTargetObject] {
        return [.decision, .item, .mission]
    }
    
    /// Returns the string values of all the enum variations.
    static let stringValues: [ActionTargetObject: String] = [
        .decision: "Decision",
        .item: "Item",
        .mission: "Mission",
    ]
    
    /// Creates an enum from a string value, if possible.
    public init?(stringValue: String?) {
        guard let type = ActionTargetObject.stringValues.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first else { return nil }
        self = type
    }
    
    /// Returns the string value of an enum.
    public var stringValue: String? {
        return ActionTargetObject.stringValues[self]
    }
}

