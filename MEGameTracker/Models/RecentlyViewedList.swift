//
//  RecentlyViewedList.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/2/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Keeps a list of recently accessed data. 
/// This is stored elsewhere in a persistent store for maps and missions.
public struct RecentlyViewedList: Codable {

    public struct Item: Codable {
        public var id: String
        public var date: Date
    }

// MARK: Constants
    enum CodingKeys: String, CodingKey {
        case maxElements
        case contents = "list"
    }

// MARK: Properties

    public static let noMaxLimit = -1

    public let maxElements: Int
    public var contents: [RecentlyViewedList.Item] = []
    public var wasChanged: Bool = false

// MARK: Initialization

    public init(maxElements: Int = RecentlyViewedList.noMaxLimit) {
        self.maxElements = maxElements
        self.contents = []
    }
}

// MARK: Basic Actions
extension RecentlyViewedList {

    /// Add a new recently viewed object to the list.
    public mutating func add(_ id: String?) {
        guard let id = id else { return }
        if let index = contents.firstIndex(where: { $0.id == id }) {
            contents.remove(at: index)
        }
        contents.insert(RecentlyViewedList.Item(id: id, date: Date()), at: 0)
        wasChanged = true
        if contents.count > maxElements {
            contents = Array(contents.prefix(maxElements))
        }
    }
}
