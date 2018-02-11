//
//  BaseDataFileImportType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/13/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public enum BaseDataFileImportType: String {
	case event = "events"
    case decision = "decisions"
    case person = "persons"
    case map = "maps"
    case item = "items"
    case mission = "missions"

    /// Creates an enum from a string value, if possible.
    public init?(stringValue: String?) {
        self.init(rawValue: stringValue ?? "")
    }

	public init?(jsonValue: String) {
        self.init(rawValue: jsonValue)
	}

	public static var list: [BaseDataFileImportType] {
		return [.decision, .event, .item, .map, .mission, .person]
	}

    /// Returns the string value of an enum.
    public var stringValue: String {
        return self.rawValue
    }
}
