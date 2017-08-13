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
public struct RecentlyViewedList {

// MARK: Properties

	public var contents: [(id: String, date: Date)] = []
	public let maxElements: Int
	public var wasChanged: Bool = false

// MARK: Initialization

	public init(maxElements: Int = -1) {
		self.maxElements = maxElements
		self.contents = []
	}
}

// MARK: Basic Actions
extension RecentlyViewedList {

	/// Add a new recently viewed object to the list.
	public mutating func add(_ id: String?) {
		guard let id = id else { return }
		if let index = contents.index(where: { $0.id == id }) {
			contents.remove(at: index)
		}
		contents.insert((id: id, date: Date()), at: 0)
		wasChanged = true
		if contents.count > maxElements {
			contents = Array(contents.prefix(maxElements))
		}
	}
}

// MARK: SerializedDataStorable
extension RecentlyViewedList: SerializedDataStorable {

	public func getData() -> SerializableData {
		var list: [String: SerializedDataStorable?] = [:]
		list["maxElements"] = maxElements
		list["list"] = SerializableData.safeInit(contents.map { ["id": $0.id.getData(), "date": $0.date.getData()] })
		return SerializableData.safeInit(list)
	}

}

// MARK: SerializedDataRetrievable
extension RecentlyViewedList: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		maxElements = data?["maxElements"]?.int ?? -1
		contents = []
		for item in data?["list"]?.array ?? [] {
			contents.append((id: item["id"]?.string ?? "0", date: item["date"]?.date as Date? ?? Date()))
		}
		wasChanged = true
	}

    public mutating func setData(_ data: SerializableData) {}
}
