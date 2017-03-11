//
//  Shepard.Appearance.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

extension Shepard {

	/// A collection of all appearance attributes by game and gender.
	/// Provides options to convert between games and create defaults.
	public struct Appearance {

// MARK: Constants

		// default shepard is not possible to create via code, so I don't bother.
		static let sampleAppearance = "XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X "

		public static let sortedAttributeGroups: [GroupType] = [
			.facialStructure,
			.head,
			.eyes,
			.jaw,
			.mouth,
			.nose,
			.hair,
			.makeup,
		]

		public static let attributeGroups: [Gender: [GroupType: [AttributeType]]] = [
			.female: [
				.facialStructure: [.facialStructure, .skinTone, .complexion, .scar],
				.head: [.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation],
				.eyes: [.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor],
				.jaw: [.chinHeight, .chinDepth, .chinWidth, .jawWidth],
				.mouth: [.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight],
				.nose: [.noseShape, .noseHeight, .noseDepth],
				.hair: [.hairColor, .hair, .brow, .browColor],
				.makeup: [.blushColor, .lipColor, .eyeShadowColor],
			],
			.male: [
				.facialStructure: [.facialStructure, .skinTone, .complexion, .scar],
				.head: [.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation],
				.eyes: [.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor],
				.jaw: [.chinHeight, .chinDepth, .chinWidth, .jawWidth],
				.mouth: [.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight],
				.nose: [.noseShape, .noseHeight, .noseDepth],
				.hair: [.beard, .brow, .hair, .hairColor, .facialHairColor],
			],
		]

		public static let attributes: [Gender: [GameVersion: [AttributeType]]] = [
			.female: [
				.game1: [
				.facialStructure, .skinTone, .complexion, .scar,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.hairColor, .hair, .brow, .browColor,
				.blushColor, .lipColor, .eyeShadowColor,
				],
				.game2: [
				.facialStructure, .skinTone, .complexion,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.hairColor, .hair, .brow, .browColor,
				.blushColor, .lipColor, .eyeShadowColor,
				],
				.game3: [
				.facialStructure, .skinTone, .complexion,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.hairColor, .hair, .brow, .browColor,
				.blushColor, .lipColor, .eyeShadowColor,
				],
			],
			.male: [
				.game1: [
				.facialStructure, .skinTone, .complexion, .scar,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.beard, .brow, .hair, .hairColor, .facialHairColor,
				],
				.game2: [
				.facialStructure, .skinTone, .complexion,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.hair, .beard, .brow, .hairColor, .facialHairColor,

				],
				.game3: [
				.facialStructure, .skinTone, .complexion,
				.neckThickness, .faceSize, .cheekWidth, .cheekBones, .cheekGaunt, .earsSize, .earsOrientation,
				.eyeShape, .eyeHeight, .eyeWidth, .eyeDepth, .browDepth, .browHeight, .irisColor,
				.chinHeight, .chinDepth, .chinWidth, .jawWidth,
				.mouthShape, .mouthDepth, .mouthWidth, .mouthLipSize, .mouthHeight,
				.noseShape, .noseHeight, .noseDepth,
				.hair, .beard, .brow, .hairColor, .facialHairColor,
				],
			]
		]

		public static let slidersMax: [Gender: [AttributeType: [GameVersion: Int]]] = {
			func sliderMaxValues(_ value1: Int, _ value2: Int, _ value3: Int) -> [GameVersion: Int] {
				return [.game1: value1, .game2: value2, .game3: value3]
			}
			return [
				.female: [
					.facialStructure: sliderMaxValues(9, 9, 9),
					.skinTone: sliderMaxValues(6, 6, 6),
					.complexion: sliderMaxValues(3, 3, 3),
					.scar: sliderMaxValues(6, 0, 0),
					.neckThickness: sliderMaxValues(31, 31, 31),
					.faceSize: sliderMaxValues(31, 31, 31),
					.cheekWidth: sliderMaxValues(31, 31, 31),
					.cheekBones: sliderMaxValues(31, 31, 31),
					.cheekGaunt: sliderMaxValues(31, 31, 31),
					.earsSize: sliderMaxValues(31, 31, 31),
					.earsOrientation: sliderMaxValues(31, 31, 31),
					.eyeShape: sliderMaxValues(9, 9, 9),
					.eyeHeight: sliderMaxValues(31, 31, 31),
					.eyeWidth: sliderMaxValues(31, 31, 31),
					.eyeDepth: sliderMaxValues(31, 31, 31),
					.browDepth: sliderMaxValues(31, 31, 31),
					.browHeight: sliderMaxValues(31, 31, 31),
					.irisColor: sliderMaxValues(13, 13, 13),
					.chinHeight: sliderMaxValues(31, 31, 31),
					.chinDepth: sliderMaxValues(31, 31, 31),
					.chinWidth: sliderMaxValues(31, 31, 31),
					.jawWidth: sliderMaxValues(31, 31, 31),
					.mouthShape: sliderMaxValues(10, 10, 10),
					.mouthDepth: sliderMaxValues(31, 31, 31),
					.mouthWidth: sliderMaxValues(31, 31, 31),
					.mouthLipSize: sliderMaxValues(31, 31, 31),
					.mouthHeight: sliderMaxValues(31, 31, 31),
					.noseShape: sliderMaxValues(9, 9, 12),
					.noseHeight: sliderMaxValues(31, 31, 31),
					.noseDepth: sliderMaxValues(31, 31, 31),
					.hairColor: sliderMaxValues(7, 7, 16),
					.hair: sliderMaxValues(10, 10, 13),
					.brow: sliderMaxValues(16, 16, 16),
					.browColor: sliderMaxValues(6, 6, 16),
					.blushColor: sliderMaxValues(6, 6, 10),
					.lipColor: sliderMaxValues(7, 7, 7),
					.eyeShadowColor: sliderMaxValues(7, 11, 11),
				],
				.male: [
					.facialStructure: sliderMaxValues(6, 6, 6),
					.skinTone: sliderMaxValues(6, 6, 6),
					.complexion: sliderMaxValues(3, 3, 3),
					.scar: sliderMaxValues(6, 0, 0),
					.neckThickness: sliderMaxValues(31, 31, 31),
					.faceSize: sliderMaxValues(31, 31, 31),
					.cheekWidth: sliderMaxValues(31, 31, 31),
					.cheekBones: sliderMaxValues(31, 31, 31),
					.cheekGaunt: sliderMaxValues(31, 31, 31),
					.earsSize: sliderMaxValues(31, 31, 31),
					.earsOrientation: sliderMaxValues(31, 31, 31),
					.eyeShape: sliderMaxValues(8, 8, 8),
					.eyeHeight: sliderMaxValues(31, 31, 31),
					.eyeWidth: sliderMaxValues(31, 31, 31),
					.eyeDepth: sliderMaxValues(31, 31, 31),
					.browDepth: sliderMaxValues(31, 31, 31),
					.browHeight: sliderMaxValues(31, 31, 31),
					.irisColor: sliderMaxValues(13, 13, 16),
					.chinHeight: sliderMaxValues(31, 31, 31),
					.chinDepth: sliderMaxValues(31, 31, 31),
					.chinWidth: sliderMaxValues(31, 31, 31),
					.jawWidth: sliderMaxValues(31, 31, 31),
					.mouthShape: sliderMaxValues(9, 9, 9),
					.mouthDepth: sliderMaxValues(31, 31, 31),
					.mouthWidth: sliderMaxValues(31, 31, 31),
					.mouthLipSize: sliderMaxValues(31, 31, 31),
					.mouthHeight: sliderMaxValues(31, 31, 31),
					.noseShape: sliderMaxValues(12, 12, 12),
					.noseHeight: sliderMaxValues(31, 31, 31),
					.noseDepth: sliderMaxValues(31, 31, 31),
					.beard: sliderMaxValues(14, 14, 14),
					.brow: sliderMaxValues(7, 7, 7),
					.hair: sliderMaxValues(8, 8, 16),
					.hairColor: sliderMaxValues(7, 7, 13),
					.facialHairColor: sliderMaxValues(6, 6, 13),
				]
			]
		}()

		public static var defaultNotices: [AttributeType: AppearanceError] = [
			.scar: AppearanceError.scarMissing
		]

// MARK: Types

		public typealias AttributeType = Shepard.AppearanceAttributeType
		public typealias AppearanceError = Shepard.AppearanceError
		public typealias Format = Shepard.AppearanceFormat
		public typealias GroupType = Shepard.AppearanceGroupType

// MARK: Properties

		public var contents: [AttributeType: Int] = [:]
		public var gender: Gender = .male
		public var gameVersion: GameVersion = .game1
		public var initError: String?

		// MARK: Alert/Notice messages on conversion failures
		public var alerts: [AttributeType: AppearanceError] = [:]
		public var notices: [AttributeType: AppearanceError] = [:]

// MARK: Initialization

		public init(gameVersion: GameVersion) {
			self.gameVersion = gameVersion
		}

		public init(
			_ appearance: String,
			fromGame gameVersion: GameVersion = .game1,
			withGender gender: Shepard.Gender = .male
		) {
			contents = [:]
			self.gameVersion = gameVersion
			self.gender = gender
			let oldAppearanceCode = Format.unformatCode(appearance)
			if let error = Format.codeLengthError(oldAppearanceCode, gender: gender, game: gameVersion) {
				initError = error
			}
			for element in oldAppearanceCode.characters {
				if let attributeList = Appearance.attributes[gender]?[gameVersion],
					attributeList.count > contents.count {
					let attribute = attributeList[contents.count]
					contents[attribute] = Format.unformatAttribute(element)
				}
			}
		}
	}
}

// MARK: Basic Actions
extension Shepard.Appearance {

	/// Converts attribute values between games.
	public mutating func convert(toGame: GameVersion) {
		alerts = [:]
		notices = [:]
		var newAppearance: [AttributeType: Int] = [:]
		if let sourceAttributes = Shepard.Appearance.attributes[gender]?[gameVersion] {
			for attribute in sourceAttributes {
				var attributeValue = contents[attribute]
				if attributeValue == nil { // not set, skip
					continue
				}
				// game 1 limited on makeup colors
				if attribute == .eyeShadowColor && toGame == .game1 {
					if attributeValue == 8 { // purple ~= pink/purple
						notices[attribute] = AppearanceError.eyeShadowColorConverted
						attributeValue = 2
					} else if attributeValue == 9 { // fuschia ~= pink
						notices[attribute] = AppearanceError.eyeShadowColorConverted
						attributeValue = 3
					} else if attributeValue == 10 { // marigold ~= coral
						notices[attribute] = AppearanceError.eyeShadowColorConverted
						attributeValue = 4
					} else if attributeValue == 11 { // green
						alerts[attribute] = AppearanceError.eyeShadowColorNotFound
						attributeValue = 0
					}
				}
				if attribute == .blushColor && toGame == .game1 {
					notices[attribute] = AppearanceError.blushColorConverted
					if attributeValue > 5 { attributeValue = 5 }
				}
				// game 3 has extra hair colors
				if (attribute == .hairColor || attribute == .browColor || attribute == .facialHairColor)
					&& gameVersion == .game3 {
					if attributeValue == 15 { // purple
						alerts[attribute] = AppearanceError.hairColorNotFound
						attributeValue = 0
					} else if attributeValue > 10 { // reds -> red
						notices[attribute] = AppearanceError.hairColorConverted
						attributeValue = 3
					} else if attributeValue > 6 { // grays
						alerts[attribute] = AppearanceError.hairColorNotFound
						attributeValue = 0
					}
				}
				// game 3 sorted hair color differently
				if attribute == .hairColor && toGame == .game3 {
					if attributeValue == 3 { // red
						notices[attribute] = AppearanceError.hairColorConverted
						attributeValue = 12
					}
				}
				// game 3 has extra hair styles
				if attribute == .hair && gameVersion == .game3 {
					if gender == .male && (attributeValue == 7 || attributeValue > 10) {
						// mohawk, other new styles
						alerts[attribute] = AppearanceError.hairNotFound
						attributeValue = 0
					}
					if gender == .male && (attributeValue == 8 || attributeValue == 9) {
						// mohawk moved things out of place
						attributeValue = attributeValue! - 1
					}
					if gender == .female && attributeValue > 9 { // rachel, knot, 60s
						alerts[attribute] = AppearanceError.hairNotFound
						attributeValue = 0
					}
				}

				// TODO: fix nose - its conversion between Game 1 and 2 female is off.

				newAppearance[attribute] = attributeValue
			}
		}
		contents = newAppearance
		gameVersion = toGame
	}

	/// Returns a formatted code, of the typical XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X format.
	public func format() -> String {
		var newAppearance = String()
		if let sourceAttributes = Shepard.Appearance.attributes[gender]?[gameVersion] {
			newAppearance = sourceAttributes.reduce("") { $0 + Format.formatAttribute(contents[$1]) }
		}
		return Format.formatCode(newAppearance)
	}

// swiftlint:disable line_length

// Notes on conversions
// FEMALE
// Lip: Matte plain, Pale pink, Vivid pink, Gold, Bright coral, Black, Gloss plain
// Eyeshadow
// ME2: Plain, Pink w/Purple liner, Pink w/Pink liner, Coral, Red, Black, Brown, Purple/Violet, Fuschia, Marigold, Leaf
// ME1: plain, purple, pink, orange, red, black, brown, plain with liner
// Haircolor:
// ME1: Blond, Dark Blond, Red, Light Brown, Brown, Dark Brown, Black
// ME3: Blond, Dark Blond, Light Brown, Brown, Dark Brown, Black, Dark Gray, Gray, Light Gray, Silver, Dark Red, Red, Bright Red, Fuschia, Purple, Dark Purple Red
// Hair:
// ME1: Shaved, Shoulder-length, Pixie, Bob, Knot (nape), Ragged Bob, French Twist, Bun (back), Bun (top), Pony tail
// ME3: Shaved, Shoulder-length, Pixie, Bob, Pulled back (hidden), Ragged Bob, French Twist, Bun (back), Bun (top), Pony tail, Short "Rachel", Bun (nape), 60s bob
// MALE
// Eye color
// ME3: Light blue, blue, Green light green, Gray, blue, dark blue, vivid blue, light brown, yellow/brown, brown, orange/brown, brown, black, red, silver
// Hair
// TODO verify the caesars - I think they were switched
// ME1: Shaved, Short styled up, Caesar, Buzz, Short slicked caesar, shaved sides, short with front styled up, bald
// ME3: Shaved, Short styled up, Caesar, Buzz, Short slicked caesar, shaved sides, mohawk, short with front styled up, bald, shaved 2, messy caesar, bald top, short with spiky front, slicked to right, slicked down messy, receding
// Haircolor:
// ME1: Blond, Dark Blond, Red, Light Brown, Brown, Dark Brown, Black
// ME3: Blond, Dark Blond, Light Brown, Brown, Dark Brown, Black, Dark Gray, Gray, Light Gray, Silver, Dark Red, Red, Bright Red

// swiftlint:enable line_length
}

// MARK: Equatable
extension Shepard.Appearance: Equatable {
	static public func == (lhs: Shepard.Appearance, rhs: Shepard.Appearance) -> Bool {
		return lhs.format() == rhs.format()
	}
}
