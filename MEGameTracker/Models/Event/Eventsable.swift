//
//  Eventsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 4/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol Eventsable {
    var gameSequenceUuid: UUID? { get }
    var events: [Event] { get set }
    var rawEventDictionary: [CodableDictionary] { get }
    func getEvents(gameSequenceUuid: UUID?, with manager: CodableCoreDataManageable?) -> [Event]
}

extension Eventsable {

    public func getEvents(gameSequenceUuid: UUID?, with manager: CodableCoreDataManageable?) -> [Event] {
        let events: [Event] = rawEventDictionary.map({
            $0.dictionary
        }).map({
            guard let id = $0["id"] as? String,
                let type = EventType(stringValue: $0["type"] as? String),
                var e = Event.get(id: id, type: type, gameSequenceUuid: gameSequenceUuid, with: manager)
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
        return getEvents(gameSequenceUuid: self.gameSequenceUuid, with: nil)
    }
}
