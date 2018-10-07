//
//  PersonType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/14/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various person types.
public enum PersonType: String, Codable, CaseIterable {

	case squad = "Squad"
	case enemy = "Enemy"
    case associate = "Associate"
    case other = "Other"

    /// Returns a list of enum variations used in PersonType categories.
    public static func categories() -> [PersonType] {
        return [
            .squad,
            .enemy,
            .associate
        ] // no .other
    }

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [PersonType: String] = [
		.squad: "Squad",
		.enemy: "Enemies",
		.associate: "Associates",
		.other: "Others",
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
		guard let type = PersonType.headingValues
			.filter({ $0.1 == headingValue }).map({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the heading string value of an enum.
	public var headingValue: String {
		return PersonType.headingValues[self] ?? "Unknown"
	}

	/// Provides a title prefix for a person of the specified enum type.
	public var titlePrefix: String {
		switch self {
		case .other: return "Person: "
		default: return "\(stringValue): "
		}
	}

}
