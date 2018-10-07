//
//  ActionTargetObject.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// Types of objects available for event actions to target.
public enum ActionTargetObject: String, Codable, CaseIterable {

	case decision = "Decision"
	case item = "Item"
	case mission = "Mission"
    case person = "Person"

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		guard let type = ActionTargetObject.allCases
			.filter({ $0.rawValue == stringValue })
			.map({ $0 })
            .first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String? {
		return rawValue
	}
}
