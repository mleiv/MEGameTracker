//
//  Shepard.PhotoPath.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	/// The default photo paths for Shepard by game version and gender.
	public struct PhotoPath {

		private typealias FilePathsByGameVersion = [GameVersion: String]

		private static let filePaths: [Shepard.Gender: FilePathsByGameVersion] = [
			.male: [
				.game1: "http://urdnot.com/megametracker/app/images/Game1/1_BroShep.png",
				.game2: "http://urdnot.com/megametracker/app/images/Game2/2_BroShep.png",
				.game3: "http://urdnot.com/megametracker/app/images/Game3/3_BroShep.png",
			],
			.female: [
				.game1: "http://urdnot.com/megametracker/app/images/Game1/1_FemShep.png",
				.game2: "http://urdnot.com/megametracker/app/images/Game2/2_FemShep.png",
				.game3: "http://urdnot.com/megametracker/app/images/Game3/3_FemShep.png",
			],
		]

		/// Get default photo filepath for this game version and gender.
		public static func defaultPath(forGender gender: Shepard.Gender, forGameVersion gameVersion: GameVersion) -> String {
			return filePaths[gender]?[gameVersion] ?? "http://urdnot.com/megametracker/app/images/Game1/1_BroShep.png"
		}
	}
}
