//
//  PersonType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/14/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various person types.
public enum PersonType: String {

	case squad, enemy, associate, other

	/// Returns a list of all possible enum variations.
	public static func list() -> [PersonType] {
		return [.squad, .enemy, .associate] // no .other
	}

	/// Returns the string values of all the enum variations.
	fileprivate static let stringValues: [PersonType: String] = [
		.squad: "Squad",
		.enemy: "Enemy",
		.associate: "Associate",
		.other: "Other",
	]

	/// Returns the heading string values of all the enum variations.
	fileprivate static let headingValues: [PersonType: String] = [
		.squad: "Squad",
		.enemy: "Enemies",
		.associate: "Associates",
		.other: "Others",
	]

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		guard let type = PersonType.stringValues
			.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return PersonType.stringValues[self] ?? "Unknown"
	}

	/// Creates an enum from a heading string value, if possible.
	public init?(headingValue: String?) {
		guard let type = PersonType.headingValues
			.filter({ $0.1 == headingValue }).flatMap({ $0.0 }).first
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
