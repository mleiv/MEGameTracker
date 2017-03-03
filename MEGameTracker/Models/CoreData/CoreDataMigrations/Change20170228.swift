//
//  Change20170228.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/28/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct Change20170228: CoreDataMigrationType {
    /// Correct some mis-saved game data
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
        
        // notes were note saved to cloudkit properly, so change them so they are stored to cloudkit next time
        let notes = Note.getAll().map { (n: Note) -> Note in var n = n; n.markChanged(); return n }
        _ = Note.saveAll(items: notes)
        
        // all game data was not dated properly in core date store
        // fix games and shepards because they rely on date
        let shepards = Shepard.getAll()
        _ = Shepard.saveAll(items: shepards)
        let games = GameSequence.getAll()
        _ = GameSequence.saveAll(items: games)
    }
}
