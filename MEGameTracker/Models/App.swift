//
//  App.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/30/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

/// A top-level manager of game data.
/// Must be a reference/class object so it can listen to signals.
final public class App {

	/// The shared app object used by everything.
	/// Warning: do not initialize any data until retrieve() is called.
	/// (Saving games before retrieve() will result in lots of dummy data filling up store)
	public static var current: App = App()

	public var hasUnsavedChanges: Bool = false
	public var postChangeWaitIntervalSeconds: TimeInterval = 60.0 * 2.0 // 2 minutes
	public let searchMaxResults = 50

	public var lastBuild: Int {
		get { return _lastBuild.get() ?? 0 }
		set { return _lastBuild.set(newValue) }
	}
		private var _lastBuild = SimpleUserDefaults<Int>(name: "LastAppBuild", defaultValue: 0)

	public var build: Int {
		if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
		   let buildInt = NumberFormatter().number(from: build)?.intValue {
			return buildInt
		}
		return 0
	}

	public var game: GameSequence?
	public var gameVersion: GameVersion { return game?.gameVersion ?? .game1 }

	/// Don't cache.
	public func getAllGames() -> [GameSequence] {
		return GameSequence.getAll(with: nil) { _ in }
	}

	public var recentlyViewedImages = RecentlyViewedImages(maxElements: 50)

	public var recentlyViewedMaps = RecentlyViewedList(maxElements: 20)

	public func addRecentlyViewedMap(mapId: String?) {
		guard let mapId = mapId else { return }
		recentlyViewedMaps.add(mapId)
		if recentlyViewedMaps.wasChanged {
			_ = save(isAllowDelay: true)
			recentlyViewedMaps.wasChanged = false
			// low priority:
			DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
				App.onRecentlyViewedMapsChange.fire(true)
			}
		}
	}

	public var recentlyViewedMissions: [GameVersion : RecentlyViewedList] = [:]

	public func addRecentlyViewedMission(missionId: String, gameVersion: GameVersion) {
		guard gameVersion == gameVersion else { return }
		var missions: RecentlyViewedList = recentlyViewedMissions[gameVersion] ?? RecentlyViewedList(maxElements: 20)
		missions.add(missionId)
		if missions.wasChanged {
			recentlyViewedMissions[gameVersion] = missions
			_ = save(isAllowDelay: true)
			recentlyViewedMissions[gameVersion]?.wasChanged = false
			// low priority:
			DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
				App.onRecentlyViewedMissionsChange.fire(true)
			}
		}
	}

	public required init() {}

	/// SerializedDataRetrievable Protocol
	public required init?(data: SerializableData?) {
		setData(data ?? SerializableData())
	}

	/// SerializedDataRetrievable Protocol
	public required convenience init?(serializedString json: String) {
		self.init(data: try? SerializableData(jsonString: json))
	}

	/// SerializedDataRetrievable Protocol
	public required convenience init?(serializedData jsonData: Data) {
		self.init(data: try? SerializableData(jsonData: jsonData))
	}

	public func initGame(uuid: String? = nil, isSave: Bool = true, isNotify: Bool = true) {
		if let uuid = uuid,
		   let newGame = GameSequence.get(uuid: uuid) {
		   // prior save
			game = newGame
		} else if let newGame = GameSequence.lastPlayed() {
			// see if there's a game we just haven't saved to this app record
			game = newGame
		} else {
			// brand new!
			game = GameSequence()
		}
		if isSave {
			_ = save(isAllowDelay: false)
		}
		if isNotify {
			fireListenerIfCurrent()
		}
	}

	public func addNewGame(isSave: Bool = true) {
		if isSave {
			_ = game?.saveAnyChanges(isAllowDelay: false)
		}
		let newGame = GameSequence()
		game = newGame
		fireListenerIfCurrent()
		if isSave {
			_ = save(isAllowDelay: false)
		}
	}

    // Thanks to new ownership rules, it is crashing on previously-harmless change/access of game. :/
	public func changeGame(isSave: Bool = true, isNotify: Bool = true, handler: ((GameSequence?) -> GameSequence?)) {
        game = handler(game)
        if isNotify {
            fireListenerIfCurrent()
        }
        if isSave {
            _ = save(isAllowDelay: false)
        }
	}

	public func delete(uuid: String) -> Bool {
		let isDeleted = GameSequence.delete(uuid: uuid)
		if uuid == game?.uuid {
			if let newGame = GameSequence.lastPlayed() {
				changeGame(isSave: false) { _ in newGame }
			}
		}
		return isDeleted
	}

	private func fireListenerIfCurrent() {
		if self == App.current {
			App.onCurrentShepardChange.fire(true)
		}
	}

	public func startListeners() {
		Shepard.onChange.cancelSubscription(for: self)
		_ = Shepard.onChange.subscribe(on: self) { [weak self] (id, shepard) in
			if id == self?.game?.shepard?.uuid {
				self?.changeGame(isSave: false) { game in
                    var game = game
                    game?.shepard = shepard
                    return game
                }
			}
		}
	}
}

// MARK: Notifications

extension App {
	public static var isInitializing: Bool = true
	public static var isDidInitialize: Bool = false
	public static let onDidInitialize = Signal<Bool>()
	public static let onCurrentShepardChange = Signal<Bool>()
	public static let onRecentlyViewedMapsChange = Signal<Bool>()
	public static let onRecentlyViewedMissionsChange = Signal<Bool>()
}

// MARK: App Open/Close

extension App {

	public func store() {
		App.current.game?.shepard?.markChanged() // force it to save timestamp to shepard
		hasUnsavedChanges = true
		_ = save(isAllowDelay: false)
	}

	public class func retrieve(uuid: String? = nil, completion: (() -> Void) = {}) {
		App.isInitializing = true
		if let app = App.get() {
			App.current = app
			if uuid != App.current.game?.uuid,
				let uuid = uuid, let game = GameSequence.get(uuid: uuid) {
				App.current.changeGame(isSave: false) { _ in game }
			}
		} else {
			// first time opening app
			App.current = App()
			App.current.initGame(uuid: uuid, isSave: false, isNotify: false)
		}
		_ = App.current.save(isAllowDelay: false)
		App.onCurrentShepardChange.fire(true)
		App.current.startListeners()
		App.isInitializing = false
		App.onDidInitialize.fire(true)
		App.isDidInitialize = true
		completion()
	}

}

// MARK: Saving/Retrieving Data

extension App: SerializedDataStorable {

	public func getData() -> SerializableData {
		var list: [String: SerializedDataStorable?] = [:]
		list["currentGameUuid"] = game?.uuid
		list["recentlyViewedMaps"] = recentlyViewedMaps
		var missionsGameVersionData: [String: SerializedDataStorable?] = [:]
		for (gameVersion, list2) in recentlyViewedMissions {
			missionsGameVersionData[gameVersion.stringValue] = list2
		}
		list["recentlyViewedMissions"] = SerializableData.safeInit(missionsGameVersionData)
		return SerializableData.safeInit(list)
	}
}

extension App: SerializedDataRetrievable {

	/// init?(data: SerializableData?) included above

	public func setData(_ data: SerializableData) {

        print("# App setData")
		initGame(uuid: data["currentGameUuid"]?.string)

		if let mapsData = data["recentlyViewedMaps"],
			let data = RecentlyViewedList(data: mapsData) {
			recentlyViewedMaps = data
		}

		recentlyViewedMissions = [:]
		if let missionsData = data["recentlyViewedMissions"]?.dictionary
								?? data["_recentlyViewedMissions"]?.dictionary {
			for (key, missionsGameVersionData) in missionsData {
				if let gameVersion = GameVersion(rawValue: key),
					let data = RecentlyViewedList(data: missionsGameVersionData) {
					recentlyViewedMissions[gameVersion] = data
				}
			}
		}
	}
}

// MARK: Equatable
extension App: Equatable {}

public func == (lhs: App, rhs: App) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
