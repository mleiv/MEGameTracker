//
//  Shepard.DefaultPhoto.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	/// The default photo paths for Shepard by game version and gender.
    public enum DefaultPhoto {
        case male(GameVersion)
        case female(GameVersion)

        var photo: Photo? {
            let fallback = "http://urdnot.com/megametracker/app/images/Game1/1_BroShep.png"
            switch self {
            case .male(let gameVersion):
                let filePath = DefaultPhoto.filePaths[.male]?[gameVersion]
                return Photo(filePath: filePath ?? fallback)
            case .female(let gameVersion):
                let filePath = DefaultPhoto.filePaths[.female]?[gameVersion]
                return Photo(filePath: filePath ?? fallback)
            }
        }

        public init(gender: Gender, gameVersion: GameVersion) {
            switch gender {
            case .male: self = .male(gameVersion)
            case .female: self = .female(gameVersion)
            }
        }

        typealias FilePathsByGameVersion = [GameVersion: String]

        static let filePaths: [Shepard.Gender: FilePathsByGameVersion] = [
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
    }
}
