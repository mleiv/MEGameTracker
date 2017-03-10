//
//  GameModifying.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/18/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Describes game properties for conforming objects.
public protocol GameModifying {

	/// This value's game identifier.
	var gameSequenceUuid: String? { get set }

	/// Flag the game as having changed when this value changes.
	func markGameChanged(with manager: SimpleSerializedCoreDataManageable?)
}

extension GameModifying {

	/// (Protocol default)
	/// Flag the game as having changed when this value changes.
	public func markGameChanged(with manager: SimpleSerializedCoreDataManageable?) {
		guard !App.isInitializing else { return }
		// don't trigger onChange event
		App.current.game?.shepard?.touch()
		_ = App.current.game?.shepard?.save(with: manager)
	}

	/// Convenience version of markGameChanged:manager (no parameters required).
	public func markGameChanged() {
		markGameChanged(with: nil)
	}
}

// MARK: Serializable Utilities
extension GameModifying where Self: SerializedDataStorable, Self: SerializedDataRetrievable {

	/// Save GameModifying values to a SerializedData dictionary.
	public func serializeGameModifyingData(
		list: [String: SerializedDataStorable?]
	) -> [String: SerializedDataStorable?] {
		var list = list
		list["gameSequenceUuid"] = gameSequenceUuid
		return list
	}

	/// Fetch GameModifying values from a SerializedData dictionary.
	public mutating func unserializeGameModifyingData(data: SerializableData) {
		gameSequenceUuid = data["gameSequenceUuid"]?.string ?? gameSequenceUuid
	}
}
