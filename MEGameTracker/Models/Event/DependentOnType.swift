//
//  DependentOnType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/17/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines a compound set of events or conditions.
public struct DependentOnType {

// MARK: Properties
    public var countTo = 1
    public var limitTo: Int?
    public var events: [String] = []
    public var decisions: [String] = []
    
}

// MARK: Basic Actions
extension DependentOnType {

    /// Determine if a compound set of events or conditions has been satisfied.
    public var isTriggered: Bool {
        var count = 0
        for id in events {
            if let event = Event.get(id: id) {
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

// MARK: SerializedDataStorable
extension DependentOnType: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["countTo"] = countTo
        list["limitTo"] = limitTo
        list["events"] = SerializableData.safeInit(events as [SerializedDataStorable])
        list["decisions"] = SerializableData.safeInit(decisions as [SerializedDataStorable])
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension DependentOnType: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data else { return nil }
        self.countTo = data["countTo"]?.int ?? 1
        self.limitTo = data["limitTo"]?.int
        self.events = (data["events"]?.array ?? []).flatMap({ $0.string })
        self.decisions = (data["decisions"]?.array ?? []).flatMap({ $0.string })
        if self.events.isEmpty && self.decisions.isEmpty { // bad data
            return nil
        }
    }
    
}
