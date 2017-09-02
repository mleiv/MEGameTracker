//
//  MEGameTrackerTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 9/9/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import XCTest
import CoreData
@testable import MEGameTracker

class MEGameTrackerTests: XCTestCase {

	let event1 = "{\"id\": \"Game1\", \"description\": \"Game 1\"}"
	let event2 = "{\"id\": \"Game2\", \"description\": \"Game 2\"}"
	let event3 = "{\"id\": \"Game3\", \"description\": \"Game 3\"}"

	var hasSandboxedManager = false

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	internal func getSandboxedManager() -> CoreDataManager {
		return CoreDataManager(storeName: CoreDataManager.defaultStoreName, isConfineToMemoryStore: true)
	}

	/// Create an app game.
	internal func initializeSandboxedStore() {
		if !hasSandboxedManager {
            CoreDataManager.current = getSandboxedManager()
			hasSandboxedManager = true
		}
	}

	/// Create an app game.
	internal func initializeCurrentGame(
		_ gameSequenceUuid: UUID? = nil,
		gender: Shepard.Gender = .male,
		with manager: CodableCoreDataManageable? = nil
	) {
		initializeSandboxedStore()
		// require a new app (don't use retrieve)
		App.current = App()
		App.current.initGame(
            uuid: gameSequenceUuid,
            isSave: true,
            isNotify: false
        )
        App.current.changeGame(isSave: false, isNotify: false) { game in
            var game = game
            game?.shepard = game?.shepard?.changed(gender: gender, isSave: true, isNotify: false)
            return game
        }
	}

	/// Create the game version events.
	/// TODO: Remove dependency on these events.
	internal func initializeGameVersionEvents() {
		initializeSandboxedStore()
		_ = create(Event.self, from: event1)
		_ = create(Event.self, from: event2)
		_ = create(Event.self, from: event3)
	}

    /// Create an object from the json given.
    internal func create<T: DataRowStorable>(
        _ type: T.Type,
        from json: String,
        with manager: CodableCoreDataManageable? = nil
    ) -> T? {
        initializeSandboxedStore()
        let manager = manager ?? CoreDataManager.current
        var item = try? manager.decoder.decode(T.self, from: json.data(using: .utf8)!)
//        print("\(String(describing: item))")
//        print("\(String(describing: String(data: (try? manager.encoder.encode(item)) ?? Data(), encoding: .utf8)))")
        _ = item?.save(with: manager)
        return item
    }

    /// Create an object from the json given.
    internal func create<T: GameRowStorable>(
        _ type: T.Type,
        from json: String,
        with manager: CodableCoreDataManageable? = nil
    ) -> T? {
        initializeSandboxedStore()
        let manager = manager ?? CoreDataManager.current
        if let data = create(T.DataRowType.self, from: json, with: manager) {
            return T.create(using: data, with: manager)
        }
        return nil
    }

    /// Create an object from the json given.
    internal func create<T: DelayedSaveRowStorable>(
        _ type: T.Type,
        from json: String,
        with manager: CodableCoreDataManageable? = nil
    ) -> T? {
        initializeSandboxedStore()
        let manager = manager ?? CoreDataManager.current
        var item = try? manager.decoder.decode(T.self, from: json.data(using: .utf8)!)
        _ = item?.save(isCascadeChanges: .none, isAllowDelay: false, with: manager)
        return item
    }

	/// Create an object from the json given.
	internal func create<T: App>(
		_ type: T.Type,
		from json: String,
		with manager: CodableCoreDataManageable? = nil
	) -> T? {
		initializeSandboxedStore()
        let manager = manager ?? CoreDataManager.current
		let item = try? manager.decoder.decode(T.self, from: json.data(using: .utf8)!)
        _ = item?.save(isCascadeChanges: .none, isAllowDelay: false, with: manager)
        return item
	}
}

public protocol DelayedSaveRowStorable: CodableCoreDataStorable {
    mutating func save(
        isCascadeChanges: EventDirection,
        isAllowDelay: Bool,
        with manager: CodableCoreDataManageable?
    ) -> Bool
}
extension Shepard: DelayedSaveRowStorable {}
extension GameSequence: DelayedSaveRowStorable {}
