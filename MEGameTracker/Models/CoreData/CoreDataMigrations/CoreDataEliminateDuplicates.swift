//
//  CoreDataEliminateDuplicates.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct CoreDataEliminateDuplicates: CoreDataMigrationType {

    public func run() {
        deleteDuplicates(type: DataDecision.self)
        deleteDuplicates(type: DataEvent.self)
        deleteDuplicates(type: DataItem.self)
        deleteDuplicates(type: DataMap.self)
        deleteDuplicates(type: DataMission.self)
        deleteDuplicates(type: DataPerson.self)
    }

    private func deleteDuplicates<T: DataRowStorable>(type: T.Type) {
        T.getAllIds()
            .reduce([String: Int]()) { var l = $0; l[$1, default: 0] += 1; return l }
            .filter { $0.1 > 1 }
            .forEach {
                let rows = T.getAll(ids: [$0.0])
                for index in 1..<rows.count {
                    var row = rows[index]
                    print("Deleted duplicate row \($0.0)")
                    _ = row.delete()
                }
            }
    }
}
