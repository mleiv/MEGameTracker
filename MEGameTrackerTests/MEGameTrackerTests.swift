//
//  MEGameTrackerTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 9/9/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import XCTest
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

	internal func getSandboxedManager() -> SimpleSerializedCoreDataManageable {
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
		_ gameSequenceUuid: String? = nil,
		gender: Shepard.Gender = .male,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) {
		initializeSandboxedStore()
		// require a new app (don't use retrieve)
		App.current = App()
		App.current.initGame(uuid: gameSequenceUuid, isSave: true, isNotify: false)
		App.current.game?.shepard?.change(gender: gender, isNotify: false)
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
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> T? {
		initializeSandboxedStore()
		var item = T(serializedString: json)
		_ = item?.save(with: manager)
		return item
	}

	/// Create an object from the json given.
	internal func create<T: GameRowStorable>(
		_ type: T.Type,
		from json: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> T? {
		initializeSandboxedStore()
		var data = T.DataRowType(serializedString: json)
		_ = data?.save(with: manager)
		if let data = data {
			return T.create(using: data, with: manager)
		}
		return nil
	}

	/// Create an object from the json given.
	internal func create<T: DelayedSaveRowStorable>(
		_ type: T.Type,
		from json: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> T? {
		initializeSandboxedStore()
		var item = T(serializedString: json)
		_ = item?.save(isCascadeChanges: .none, isAllowDelay: false, with: manager)
		return item
	}

	/// Create an object from the json given.
	internal func create<T: App>(
		_ type: T.Type,
		from json: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> T? {
		initializeSandboxedStore()
		let item = T(serializedString: json) // reference class
		_ = item?.save(isCascadeChanges: .none, isAllowDelay: false, with: manager)
		return item
	}
}
public protocol DelayedSaveRowStorable: SimpleSerializedCoreDataStorable {
	mutating func save(
		isCascadeChanges: EventDirection,
		isAllowDelay: Bool,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool
}

extension Shepard: DelayedSaveRowStorable {}

extension GameSequence: DelayedSaveRowStorable {}
