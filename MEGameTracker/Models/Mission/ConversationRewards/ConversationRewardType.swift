//
//  ConversationRewardType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// The varying results for a conversation.
public enum ConversationRewardType: String, Codable {
	case paragon = "Paragon"
	case renegade = "Renegade"
	case paragade = "Paragade"
	case neutral = "Neutral"
	case credits = "Credits"

	/// Returns a list of all possible enum variations.
	public static func all() -> [ConversationRewardType] {
		return [
            .paragon,
            .renegade,
            .paragade,
            .neutral,
            .credits
        ]
	}

	/// Returns the string values of all the enum variations.
	private static let stringValues: [ConversationRewardType: String] = {
        return Dictionary(uniqueKeysWithValues: all().map { ($0, $0.stringValue) })
    }()

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		self.init(rawValue: stringValue ?? "")
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return rawValue
	}

}
