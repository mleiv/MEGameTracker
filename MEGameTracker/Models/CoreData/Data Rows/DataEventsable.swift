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
    var rawEventData: SerializableData? { get }
    
    /// A reference to the current core data manager.
    /// (Default provided for SimpleSerializedCoreDataStorable objects.)
    var defaultManager: SimpleSerializedCoreDataManageable { get }
}

extension DataEventsable {
    
    public func getRelatedDataEvents(
        context: NSManagedObjectContext?
    ) -> NSSet {
        let ids: [String] = (rawEventData?.array ?? []).flatMap({ $0["id"]?.string })
        guard !ids.isEmpty else { return NSSet() }
        let manager = type(of: defaultManager).init(context: context)
        let directEvents = DataEvent.getAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K in %@)", #keyPath(DataEvents.id), ids)
        }
        let relatedEventIds = ids + directEvents.flatMap({ $0.dependentOn?.events ?? [] })
        let allEvents: [DataEvents] = manager.getAll() { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K in %@)", #keyPath(DataEvents.id), relatedEventIds)
        }
        return NSSet(array: allEvents)
    }
}
