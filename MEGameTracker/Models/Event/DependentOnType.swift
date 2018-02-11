//
//  DependentOnType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/17/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines a compound set of events or conditions.
public struct DependentOnType: Codable {

    enum CodingKeys: String, CodingKey {
        case countTo
        case limitTo
        case events
        case decisions
    }

// MARK: Properties
	public var countTo = 1
	public var limitTo: Int?
	public var events: [String] = []
	public var decisions: [String] = []

	private let anyMissionPrefix = "Any Mission After:"

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countTo = try container.decode(Int.self, forKey: .countTo)
        limitTo = try container.decodeIfPresent(Int.self, forKey: .limitTo)
        events = (try container.decodeIfPresent([String].self, forKey: .events)) ?? events
        decisions = (try container.decodeIfPresent([String].self, forKey: .decisions)) ?? decisions
    }
}

// MARK: Basic Actions
extension DependentOnType {

	/// Determine if a compound set of events or conditions has been satisfied.
	public var isTriggered: Bool {
		var count = 0
		for id in events {
			if id.contains(anyMissionPrefix) {
				let eventId = String(id[id.index(
                    id.startIndex,
                    offsetBy: anyMissionPrefix.count + 1
                )...])
                if let event = Event.get(id: eventId),
                    event.isTriggered,
                    let triggeredDate = event.triggeredDate,
                    let gameVersion = event.gameVersion {
                    count += Mission.getCompletedCount(
                        after: triggeredDate,
                        missionType: .mission,
                        gameVersion: gameVersion
                    )
print("\(id) \(count)")
				}
			} else if let event = Event.get(id: id) {
				count += event.isTriggered ? 1 : 0
			}
		}
		for id in decisions {
			if let decision = Decision.get(id: id) {
				count += decision.isSelected ? 1 : 0
			}
		}
		if let limitTo = self.limitTo {
			return count >= countTo && count <= limitTo
		} else {
			return count >= countTo
		}
	}
}
