//
//  Change20170905.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/4/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct Change20170905: CoreDataMigrationType {
    let oldItemIds = [
        "A1.C1.ScanTheKeepers.I.1",
        "A1.C1.ScanTheKeepers.I.2",
        "A1.C1.ScanTheKeepers.I.3",
        "A1.C1.ScanTheKeepers.I.4",
        "A1.C1.ScanTheKeepers.I.5",
        "A1.C1.ScanTheKeepers.I.6",
        "A1.C1.ScanTheKeepers.I.7",
        "A1.C1.ScanTheKeepers.I.8",
        "A1.C1.ScanTheKeepers.I.9",
    ]
    let newItemIds = [
        "A1.C1.ScanTheKeepers.I.01",
        "A1.C1.ScanTheKeepers.I.02",
        "A1.C1.ScanTheKeepers.I.03",
        "A1.C1.ScanTheKeepers.I.04",
        "A1.C1.ScanTheKeepers.I.05",
        "A1.C1.ScanTheKeepers.I.06",
        "A1.C1.ScanTheKeepers.I.07",
        "A1.C1.ScanTheKeepers.I.08",
        "A1.C1.ScanTheKeepers.I.09",
    ]

    /// Correct some changes ids - we renamed them to correct item sort order.
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
        // load the old items.
        for index in 0..<oldItemIds.count {
            guard var fromItem = Item.getExisting(
                id: oldItemIds[index],
                gameSequenceUuid: nil
            ) else { continue }
            if let toItem = Item.get(
                id: newItemIds[index],
                gameSequenceUuid: fromItem.gameSequenceUuid
            ) {
                _ = toItem.changed(isAcquired: fromItem.isAcquired)
            }
            // delete the old items.
            _ = fromItem.delete()
        }
        // delete the old data items.
        _ = DataItem.deleteAll(ids: oldItemIds)
    }
}
