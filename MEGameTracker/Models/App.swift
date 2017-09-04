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
final public class App: Codable {

    /// The shared app object used by everything.
    /// Warning: do not initialize any data until retrieve() is called.
    /// (Saving games before retrieve() will result in lots of dummy data filling up store)
    public static var current: App = App()

    enum CodingKeys: String, CodingKey {
        case currentGameUuid
        case recentlyViewedMaps
        case recentlyViewedMissions
    }

// MARK: Constants
    public var postChangeWaitIntervalSeconds: TimeInterval = 60.0 * 2.0 // 2 minutes

    public let searchMaxResults = 50

    static let defaultRecentlyViewedListSize = 20

// MARK: Properties
    public var rawData: Data? { get { return nil } set {} } // block this behavior
    
    public var currentGameUuid: UUID?

    public var recentlyViewedMaps: RecentlyViewedList

    public var recentlyViewedMissions: [GameVersion : RecentlyViewedList]

    public var game: GameSequence?

    public var recentlyViewedImages = RecentlyViewedImages(maxElements: 50) // not saved

// MARK: Computed Properties
    public var gameVersion: GameVersion { return game?.gameVersion ?? .game1 }

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

// MARK: Change Listeners And Change Status Flags

    public var hasUnsavedChanges = false
    public static var onChange = Signal<(id: String, object: Decision?)>()

// MARK: Initialization

    public required init() {
        currentGameUuid = UUID()
        recentlyViewedMaps = RecentlyViewedList(maxElements: App.defaultRecentlyViewedListSize)
        recentlyViewedMissions = [:]
    }

    // Decoder Protocol
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        currentGameUuid = try container.decodeIfPresent(UUID.self, forKey: .currentGameUuid)
        recentlyViewedMaps = try container.decodeIfPresent(
                RecentlyViewedList.self,
                forKey: .recentlyViewedMaps
            ) ?? RecentlyViewedList(maxElements: App.defaultRecentlyViewedListSize)
        recentlyViewedMissions = [:]
        let missionsContainer = try? container.nestedContainer(
            keyedBy: GameVersion.self,
            forKey: .recentlyViewedMissions)
        for gameVersion in GameVersion.all() {
            recentlyViewedMissions[gameVersion] = try missionsContainer?.decodeIfPresent(
                    RecentlyViewedList.self,
                    forKey: gameVersion
                ) ?? RecentlyViewedList(maxElements: App.defaultRecentlyViewedListSize)
        }
    }

    public func initGame(uuid: UUID? = nil, isSave: Bool = true, isNotify: Bool = true) {
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
        currentGameUuid = game?.uuid
        if isSave {
            _ = save(isAllowDelay: false)
        }
        if isNotify {
            fireListenerIfCurrent()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentGameUuid, forKey: .currentGameUuid)
        try container.encode(recentlyViewedMaps, forKey: .recentlyViewedMaps)
        var missionsContainer = container.nestedContainer(
            keyedBy: GameVersion.self,
            forKey: .recentlyViewedMissions)
        for (gameVersion, list) in recentlyViewedMissions {
            try missionsContainer.encode(list, forKey: gameVersion)
        }
    }
}

// MARK: Data Change Actions
extension App {

	public func getAllGames() -> [GameSequence] {
		return GameSequence.getAll(with: nil) { _ in }
	}

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
        currentGameUuid = game?.uuid
        if isNotify {
            fireListenerIfCurrent()
        }
        if isSave {
            _ = save(isAllowDelay: false)
        }
	}

	public func delete(uuid: UUID) -> Bool {
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
            if let id = UUID(uuidString: id), id == self?.game?.shepard?.uuid {
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

	public class func retrieve(uuid: UUID? = nil, completion: (() -> Void) = {}) {
		App.isInitializing = true
		if let app = App.get() {
            if let uuid = uuid,
                uuid != app.currentGameUuid,
                let game = GameSequence.get(uuid: uuid) {
				app.changeGame(isSave: false, isNotify: false) { _ in game }
			} else {
                // not specified, load prior game
                app.initGame(uuid: app.currentGameUuid, isSave: false, isNotify: false)
            }
            App.current = app
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

// MARK: Equatable
extension App: Equatable {}

public func == (lhs: App, rhs: App) -> Bool {
	return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
