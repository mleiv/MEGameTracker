//
//  ConversationRewardType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// The varying results for a conversation.
public enum ConversationRewardType {
	case paragon, renegade, paragade, credits

	/// Returns a list of all possible enum variations.
	public static func list() -> [ConversationRewardType] {
		return [.paragon, .renegade, .paragade, .credits]
	}

	/// Returns the string values of all the enum variations.
	fileprivate static let stringValues: [ConversationRewardType: String] = [
		.paragon: "Paragon",
		.renegade: "Renegade",
		.paragade: "Paragade",
		.credits: "Credits",
	]

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		guard let type = ConversationRewardType.stringValues
			.filter({ $0.1 == stringValue }).flatMap({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return ConversationRewardType.stringValues[self] ?? "Unknown"
	}

}
