//
//  Eventsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 4/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol Eventsable {
	var events: [Event] { get set }
	var rawEventData: SerializableData? { get }
	func getEvents(with manager: SimpleSerializedCoreDataManageable?) -> [Event]
}

extension Eventsable {

	public func getEvents(with manager: SimpleSerializedCoreDataManageable?) -> [Event] {
		let events: [Event] = (rawEventData?.array ?? []).map({
			guard let id = $0["id"]?.string,
				let type = EventType(stringValue: $0["type"]?.string),
				var e = Event.get(id: id, type: type, with: manager)
			else { return nil }
			// store what object is holding this at present:
			if let mission = self as? Mission {
				e.inMissionId = mission.id
			} else if let map = self as? Map {
				e.inMapId = map.id
			} else if let person = self as? Person {
				e.inPersonId = person.id
			} else if let item = self as? Item {
				e.inItemId = item.id
			}
			return e
		}).filter({ $0 != nil }).map({ $0! })
		return events
	}

	public func getEvents() -> [Event] {
		return getEvents(with: nil)
	}
}
