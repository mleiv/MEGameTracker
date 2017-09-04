//
//  CodableCoreDataStorable+CodableDictionary.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

extension CodableCoreDataStorable {
    /// (Protocol default)
    /// Applies a dictionary data set of changes, and returns an updated copy of the object.
    /// It is not very efficient
    /// - it just merges the dictionary with the source data and re-extracts it using Codable.
    public func changed(
        _ changes: [String: Any?]
    ) -> Self {
        guard !changes.isEmpty else { return self }
        let combined = CodableDictionary(
            getBaseData().merging(changes) { (_, new) in new }
        )
        if let data = try? defaultManager.encoder.encode(combined),
            let changed = try? defaultManager.decoder.decode(Self.self, from: data) {
            // rawData should now be nil
            return changed
        }
        return self
    }

    /// Either fetch the rawData cache or create Data from current object.
    /// Return as a dictionary.
    private func getBaseData() -> [String: Any?] {
        let data: Data = {
            if let rawData = self.rawData {
                return rawData
            } else if let data = try? defaultManager.encoder.encode(self) {
                return data
            }
            return Data()
        }()
        let codableDictionary = try? defaultManager.decoder.decode(CodableDictionary.self, from: data)
        return codableDictionary?.dictionary ?? [:]
    }
}
