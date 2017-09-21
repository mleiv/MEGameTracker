//
//  DataEventsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 4/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public protocol DataEventsable {

    /// The serialized event data stored (can be edited, like during base import, but this is not recommended)
    var rawEventDictionary: [CodableDictionary] { get }

    /// A reference to the current core data manager.
    /// (Default provided for CodableCoreDataStorable objects.)
    var defaultManager: CodableCoreDataManageable { get }
}

extension DataEventsable {
    typealias DataEventsableType = DataEvent

//    public func getDataEvents(with manager: CodableCoreDataManageable?) -> [DataEvent] {
//        let manager = manager ?? CoreDataManager.current
//        return (try? manager.decoder.decode([DataEvent].self, from: rawEventDictionary)) ?? []
//    }

    public func getRelatedDataEvents(
        context: NSManagedObjectContext?
    ) -> NSSet {
        let ids = getIdsFromrawEventDictionary()
        guard !ids.isEmpty else { return NSSet() }
        let manager = type(of: defaultManager).init(context: context)
        let directEvents = DataEvent.getAll(ids: ids, with: manager)
        let relatedEventIds = ids + directEvents.flatMap({ $0.dependentOn?.events ?? [] }) // yes Flat Map
        let allEvents: [DataEvents] = manager.getAll { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K in %@)", #keyPath(DataEvents.id), relatedEventIds)
        }
        return NSSet(array: allEvents)
    }

    private func getIdsFromrawEventDictionary() -> [String] {
        return rawEventDictionary.map { $0["id"] as? String }.filter({ $0 != nil }).map({ $0! })
    }
}

private struct DataEventsableDecodedEventId: Codable {
    let id: String
}
