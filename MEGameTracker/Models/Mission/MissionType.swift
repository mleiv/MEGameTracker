//
//  MissionType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines various mission types.
public enum MissionType: String, Codable {

	case mission = "Mission"
	case assignment = "Assignment"
	case dossier = "Dossier"
	case loyalty = "Loyalty"
	case dlc = "DLC"
	case collection = "Collection"
	case upgrade = "Upgrade"
	case task = "Task"
	case conversation = "Conversation"
	case objective = "Objective"
	case subset = "Set"

	/// Returns a list of all possible enum variations.
	public static func all() -> [MissionType] {
		return [
			.mission,
			.assignment,
			.dossier,
			.loyalty,
			.dlc,
			.collection,
			.upgrade,
			.task,
			.conversation,
			.objective,
			.subset,
		]
	}

    /// Returns a list of enum variations used in MissionType categories.
	public static func categories() -> [MissionType] {
		return [
			.mission,
			.assignment,
			.dossier,
			.loyalty,
			.dlc,
			.collection,
			.upgrade,
			.conversation,
			.task,
		]
	}

    public static var anyMissionTriggers: [MissionType] {
        return [.mission, .assignment, .dossier, .loyalty, .dlc]
    }

	/// Returns the string values of all the enum variations.
	private static let stringValues: [MissionType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Returns the heading string values of all the enum variations.
	private static let headingValues: [MissionType: String] = [
		.mission: "Missions",
		.assignment: "Assignments",
		.dossier: "Dossiers",
		.loyalty: "Loyalty",
		.dlc: "DLCs",
		.collection: "Collections",
		.upgrade: "Upgrades",
		.task: "Tasks",
		.conversation: "Conversations",
		.subset: "Sets",
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
		guard let type = MissionType.headingValues
			.filter({ $0.1 == headingValue }).map({ $0.0 }).filter({ $0 != nil }).map({ $0! }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the heading string value of an enum.
	public var headingValue: String {
		return MissionType.headingValues[self] ?? "Unknown"
	}

	/// Returns the int value of an enum.
	public var intValue: Int? {
        return MissionType.all().index(of: self)
	}

	/// Provides a title prefix for a mission of the specified enum type.
	public var titlePrefix: String {
		switch self {
		case .conversation: return "\(headingValue): " // use plural - makes more sense as they are collections
		case .mission: fallthrough
		case .assignment: fallthrough
		case .collection: fallthrough
		case .subset: return ""
		default: return "\(stringValue): "
		}
	}

    public var isAnyMissionTrigger: Bool {
        return MissionType.anyMissionTriggers.contains(self)
    }
}
