//
//  ShepardTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
import Nuke
@testable import MEGameTracker

final class ShepardTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let broShepGameSequenceUuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29520")!

	let broShep1Json = "{\"uuid\" : \"B6D0BD56-9CA9-4060-8F2E-E4DFE4EEE8A2\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-26 01:59:19\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29520\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-26 05:15:40\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.217.65\",\"class\" : \"Soldier\",\"gender\" : \"M\",\"name\" : \"John\", \"loveInterestId\": \"S1.Ashley\"}"

	// femal equivalent game 1 432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.671.XXX.X
	// game 2 432.FLC.JCI.F6F.JHI.I7I.JHK.4KE.FJ8.HH7.216.5

	let femShepGameSequenceUuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29519")!

	let femShep1Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	let femShep2Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFE\",\"gameVersion\" : \"2\",\"paragon\" : 0,\"createdDate\" : \"2017-02-25 09:10:15\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-25 09:10:15\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	let ashleyJson = "{\"id\": \"S1.Ashley\",\"name\": \"Ashley Williams\",\"personType\": \"Squad\",\"isMaleLoveInterest\": true,\"race\": \"Human\",\"profession\": \"Soldier\",\"organization\": \"Systems Alliance\",\"loveInterestDecisionId\": \"D1.LoveAshley\"}"

	let liaraJson = "{\"id\": \"S1.Liara\",\"name\": \"Liara T\'soni\",\"personType\": \"Squad\",\"isMaleLoveInterest\": true,\"isFemaleLoveInterest\": true,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"loveInterestDecisionId\": \"D1.LoveLiara\"}"

	let loveInterestDecision1Json = "{\"id\": \"D1.LoveAshley\",\"gameVersion\": \"1\",\"name\": \"Romanced Ashley\",\"description\": \"Provides a Paramour achievement. Only one romantic partner is allowed.\",\"loveInterestId\": \"S1.Ashley\",\"blocksDecisionIds\": [\"D1.LoveKaidan\", \"D1.LoveLiara\"],\"sortIndex\": 100}"

	let loveInterestDecision2Json = "{\"id\": \"D1.LoveLiara\",\"gameVersion\": \"1\",\"name\": \"Romanced Liara\",\"description\": \"Provides a Paramour achievement. Only one romantic partner is allowed.\",\"loveInterestId\": \"S1.Liara\",\"blocksDecisionIds\": [\"D1.LoveKaidan\", \"D1.LoveAshley\"],\"sortIndex\": 100}"

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let shepard1 = create(Shepard.self, from: femShep1Json)
		let shepard2 = create(Shepard.self, from: femShep1Json)
		XCTAssert(shepard1 == shepard2, "Equality not working")
	}

	// TODO: signal test for current shepard

	/// Test Shepard get methods.
	func testGetOne() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for game version
        App.current.changeGame { game in
            var game = game
            _ = game?.shepard?.delete()
            game?.shepard = create(Shepard.self, from: femShep1Json)
            return game
        }
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
		let shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.fullName == "Xoe Shepard", "Failed to load by id")
	}

	/// Test Shepard getAll methods.
	func testGetAll() {
		_ = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)
		_ = create(Shepard.self, from: broShep1Json)
		let shepards = Shepard.getAll()
		XCTAssert(shepards.count == 3, "Failed to get all shepards")
	}

	/// Test Shepard get last played
	func testGetByLastPlayed() {
		_ = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)
		let shepard = Shepard.lastPlayed(gameSequenceUuid: femShepGameSequenceUuid)
		XCTAssert(shepard?.gameVersion == .game2, "Failed to get correct last played shepard")
	}

	/// Test Shepard loaded by parent game
	func testGetByGame() {
		_ = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)
		let shepards = Shepard.getAll(gameSequenceUuid: femShepGameSequenceUuid)
		XCTAssert(shepards.count == 2, "Failed to get game shepards")
	}

	/// Test Shepard change action.
	func testChangeName() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(name: "Xena")
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
		shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.fullName == "Xena Shepard", "Failed to change name")

		// make sure change was propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
		shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.fullName == "Xena Shepard", "Failed to change name on other version")

		// make sure custom names aren't changed when gender changes:
		_ = shepard?.changed(gender: .male)
		shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.fullName == "Xena Shepard", "Incorrectly gender-changed name")
	}

	/// Test Shepard change action.
	func testChangeClass() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(class: .adept)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.classTalent == .adept, "Failed to change class")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.classTalent == .soldier, "Incorrectly changed class on other version")
	}

	/// Test Shepard change action.
	func testChangeOrigin() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(origin: .colonist)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.origin == .colonist, "Failed to change origin")

		// make sure change was propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.origin == .colonist, "Failed to change origin on other version")
	}

	/// Test Shepard change action.
	func testChangeReputation() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(reputation: .ruthless)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.reputation == .ruthless, "Failed to change reputation")

		// make sure change was propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.reputation == .ruthless, "Failed to change reputation on other version")
	}

	/// Test Shepard photo change action.
	func testChangePhoto() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		// #1) Share custom image across shepard
		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		guard let image = UIImage(named: "Heart Filled") else {
			return XCTAssert(false, "Failed to create an image")
		}

		_ = shepard?.savePhoto(image: image, isSave: true)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.photo?.isCustomSavedPhoto == true, "Failed to customize photo")

		// check change was propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
        let lastChanged = shepard?.modifiedDate
		XCTAssert(shepard?.photo?.isCustomSavedPhoto == true, "Failed to customize photo on other version")

        sleep(1)

		// #2) Don't share if other version already has a custom image
		guard let image2 = UIImage(named: "Heart Empty") else {
			return XCTAssert(false, "Failed to create an image")
		}

        shepard = Shepard.get(uuid: uuid)
        _ = shepard?.savePhoto(image: image2, isSave: true)

		// check change was NOT propogated to other versions:
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.modifiedDate == lastChanged, "Incorrectly customized photo on other version")
	}

	/// Test Shepard change action.
	func testChangeAppearance() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		let appearance = Shepard.Appearance("432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.671.XXX.X")
		_ = shepard?.changed(appearance: appearance)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.appearance.format() == "432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.671.XXX.X", "Failed to change appearance")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.appearance.format() == "XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX", "Incorrectly changed appearance on other version")
	}

	/// Test Shepard change action.
	func testChangeLevel() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(level: 10)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.level == 10, "Failed to change level")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.level == 1, "Incorrectly changed level on other version")
	}

	/// Test Shepard change action.
	func testChangeParagon() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(paragon: 80)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.paragon == 80, "Failed to change paragon")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.paragon == 0, "Incorrectly changed paragon on other version")
	}

	/// Test Shepard change action.
	func testChangeRenegade() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(renegade: 80)
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.renegade == 80, "Failed to change renegade")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.renegade == 0, "Incorrectly changed renegade on other version")
	}

	/// Test Shepard change action.
	func testChangeLoveInterest() {
		initializeCurrentGame(femShepGameSequenceUuid) // needed for saving with game uuid
		_ = create(Decision.self, from: loveInterestDecision1Json)
		_ = create(Person.self, from: ashleyJson)

		var shepard = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)

		_ = shepard?.changed(loveInterestId: "D1.LoveAshley")
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFD")!
        shepard = Shepard.get(uuid: uuid)
		XCTAssert(shepard?.loveInterestId ==  "D1.LoveAshley", "Failed to change love interest")

		// make sure change was NOT propogated to other versions:
        let uuid2 = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.loveInterestId == nil, "Incorrectly changed love interest on other version")
	}

	/// Test Shepard change action.
	func testChangeGender() {
		initializeCurrentGame(broShepGameSequenceUuid) // needed for saving with game uuid
		_ = create(Decision.self, from: loveInterestDecision1Json)
		_ = create(Decision.self, from: loveInterestDecision2Json)
		_ = create(Person.self, from: ashleyJson)
		_ = create(Person.self, from: liaraJson)

		// set up
        App.current.changeGame { game in
            var game = game
            _ = game?.shepard?.delete()
            game?.shepard = create(Shepard.self, from: broShep1Json)
            return game
        }
		var shepard = App.current.game?.shepard

		// male values
		XCTAssert(shepard?.gender == .male, "Incorrect initial gender")
		XCTAssert(shepard?.fullName == "John Shepard", "Incorrect initial name")
		XCTAssert(shepard?.photo?.filePath == "http://urdnot.com/megametracker/app/images/Game1/1_BroShep.png", "Incorrect initial photo")
		XCTAssert(shepard?.loveInterestId == "S1.Ashley", "Incorrect initial love interest")
		XCTAssert(shepard?.appearance.format() == "432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.217.65", "Incorrect initial appearance")

		// change
		_ = shepard?.changed(gender: .female)
        let uuid2 = UUID(uuidString: "B6D0BD56-9CA9-4060-8F2E-E4DFE4EEE8A2")!
        shepard = Shepard.get(uuid: uuid2)

		// female values
		XCTAssert(shepard?.gender == .female, "Failed to change gender")
		XCTAssert(shepard?.fullName == "Jane Shepard", "Failed to gender-change default name")
		XCTAssert(shepard?.photo?.filePath == "http://urdnot.com/megametracker/app/images/Game1/1_FemShep.png", "Failed to gender-change default photo")
		XCTAssert(shepard?.loveInterestId == nil, "Failed to gender-change love interest")
		XCTAssert(shepard?.appearance.format() == "432.4FL.CJC.IF6.FJH.II7.IJH.K4K.EFJ.8HH.671.XXX.X", "Failed to gender-change appearance")

		// verify love interest is not changed when love interest is bisexual
		_ = shepard?.changed(loveInterestId: "S1.Liara").changed(gender: .male)
        shepard = Shepard.get(uuid: uuid2)
		XCTAssert(shepard?.loveInterestId == "S1.Liara", "Incorrect gender-change love interest")
	}

	/// Test Shepard change action.
	func testCreateNewVersion() {
		initializeCurrentGame(broShepGameSequenceUuid) // needed for saving with game uuid

		// set up
		App.current.changeGame { game in
            var game = game
            _ = game?.shepard?.delete()
            game?.shepard = create(Shepard.self, from: broShep1Json)
            return game
        }
		let shepard1 = App.current.game?.shepard

		App.current.game?.change(gameVersion: .game2)
		let shepard2 = App.current.game?.shepard

		// female values
		XCTAssert(shepard2?.gender == shepard1?.gender, "New game version shepard has incorrect gender")
		XCTAssert(shepard2?.fullName == shepard1?.fullName, "New game version shepard has incorrect name")
		XCTAssert(shepard2?.photo?.filePath == "http://urdnot.com/megametracker/app/images/Game2/2_BroShep.png", "New game version shepard has incorrect photo")
		XCTAssert(shepard2?.loveInterestId == nil, "New game version shepard has incorrect love interest")
		XCTAssert(shepard2?.appearance.format() == "432.FLC.JCI.F6F.JHI.I7I.JHK.4KE.FJ8.HH7.216.5", "New game version shepard has incorrect appearance")
		XCTAssert(shepard2?.classTalent == shepard1?.classTalent, "New game version shepard has incorrect class")
		XCTAssert(shepard2?.reputation == shepard1?.reputation, "New game version shepard has incorrect reputation")
		XCTAssert(shepard2?.origin == shepard1?.origin, "New game version shepard has incorrect origin")
		XCTAssert(shepard2?.level == 1, "New game version shepard has incorrect level")
		XCTAssert(shepard2?.renegade == 0, "New game version shepard has incorrect renegade")
		XCTAssert(shepard2?.paragon == 0, "New game version shepard has incorrect paragon")
	}

	// swiftlint:enable line_length
}
