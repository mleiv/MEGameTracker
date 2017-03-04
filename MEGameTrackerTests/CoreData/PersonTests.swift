//
//  PersonTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/22/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class PersonTests: MEGameTrackerTests {

    let liaraJson = "{\"id\": \"S1.Liara\",\"name\": \"Liara T\'soni\",\"description\": \"An archeologist specializing in the ancient prothean culture, Liara is the \\\"pureblood\\\" daughter of [megametracker:\\/\\/person?id=E1.Benezia]. At 106 - young for an asari - she has eschewed the typical frivolities of youth and instead pursued her research.\",\"personType\": \"Squad\",\"isMaleLoveInterest\": 1,\"isFemaleLoveInterest\": 1,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game1\\/1Liara.png\",\"voiceActor\": \"Ali Hillis\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Liara_T%27Soni\"],\"relatedMissionIds\": [\"M1.Therum\"],\"relatedDecisionIds\": [\"D1.LoveLiara\", \"D2.LoveLiara\", \"D3.LoveLiara\"],\"loveInterestDecisionId\": \"D1.LoveLiara\",\"gameVersionData\": {\"2\": {\"personType\": \"Associate\",\"profession\": \"Information Broker\",\"description\": \"Liara was a close friend, but now she has her own agenda on Illium, turning her research skills to hunting valuable secrets, and she only briefly allies with Shepard for the Lair of the Shadow Broker (DLC) missions.\\n\\nPursuing her as a love interest in Game 2 is difficult but not impossible [Romancing Liara in Game 2|https:\\/\\/masseffect.wikia.com\\/wiki\\/Romance#Lair_of_the_Shadow_Broker].\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game2\\/2Liara.png\",\"loveInterestDecisionId\": \"D2.LoveLiara\"},\"3\": {\"profession\": \"Pure Biotic\",\"description\": \"After a Cerberus raid destroyed the Shadow Broker\'s lair, Liara fled with all the resources she could take with her. She is using all her Shadow Broker assets to search for a way to fight the Reapers, and she may have found it in the Mars Archives.\",\"loveInterestDecisionId\": \"D3.LoveLiara\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game3\\/3Liara.png\"}}}"
    
    let kaidanJson = "{\"id\": \"S1.Kaidan\",\"name\": \"Kaidan Alenko\",\"description\": \"Staff Lieutenant aboard the Normandy, Kaiden is the first addition to Shepard\'s squad. Kaidan\'s biotic abilities came at a high cost, emotionally and physically, and the older L2 implants cause him constant migraines.\",\"personType\": \"Squad\",\"isFemaleLoveInterest\": 1,\"race\": \"Human\",\"profession\": \"Sentinel\",\"organization\": \"Systems Alliance\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game1\\/1Kaidan.png\",\"voiceActor\": \"Raphael Sbarge\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Kaidan_Alenko\"],\"relatedMissionIds\": [\"M1.Prologue\", \"M1.Virmire.10\"],\"relatedDecisionIds\": [\"D1.Kaidan\", \"D1.LoveKaidan\", \"D3.LoveKaidan\"],\"loveInterestDecisionId\": \"D1.LoveKaidan\",\"sideEffects\": [\"If you make bad decisions in Game 3, you are forced to kill Kaidan during [megametracker:\\/\\/mission?id=M3.2.Citadel2]: [YouTube|https:\\/\\/www.youtube.com\\/watch?v=XDnp86lUnB4].\"],\"gameVersionData\": {\"2\": {\"personType\": \"Associate\",\"isFemaleLoveInterest\": 0,\"description\": \"A loyal friend and former squadmate, Kaidan has mixed feelings seeing Shepard alive but working for Cerberus on Horizon. He is suspicious that Cerberus has tampered with Shepard\'s mind.\",\"loveInterestDecisionId\": null,\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game2\\/2Kaidan.png\"},\"3\": {\"description\": \"Kaiden begins Game 3 on Shepard\'s team, but whether he remains depends on how hard Shepard works to persuade him that Cerberus didn\'t change Shepard in Game 2.\",\"loveInterestDecisionId\": \"D3.LoveKaidan\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game3\\/3Kaidan.png\"}}}"
    
    let sarenJson = "{\"id\": \"E1.Saren\",\"name\": \"Saren Arterius\",\"description\": \"A cunning and ruthless Spectre - the unregulated arm of Citadel enforcement - Saren is viciously and openly anti-human. It appears he has aligned himself with [Matriarch Benezia|megametracker:\\/\\/person?id=E1.Benezia] and the mysterious [Sovereign|megametracker:\\/\\/person?id=E1.Sovereign], intent on destroying all life in the galaxy.\",\"personType\": \"Enemy\",\"race\": \"Turian\",\"profession\": \"Spectre\",\"organization\": \"Citadel Council\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game1\\/1Saren.png\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Saren_Arterius\"],\"voiceActor\": \"Fred Tatasciore\",\"relatedMissionIds\": [\"M1.Prologue\", \"M1.ExposeSaren\", \"M1.Virmire\", \"M1.RaceAgainstTime\", \"M1.Ilos\"],\"events\": [{\"type\": \"UnavailableInGame\",\"id\": \"Game2\"}, {\"type\": \"UnavailableInGame\",\"id\": \"Game3\"}]}"
    
    let loveInterestDecisionJson = "{\"id\": \"D1.LoveLiara\",\"gameVersion\": \"1\",\"name\": \"Romanced Liara\",\"description\": \"Provides a Paramour achievement. Only one romantic partner is allowed.\",\"loveInterestId\": \"S1.Liara\",\"blocksDecisionIds\": [\"D1.LoveKaidan\", \"D1.LoveAshley\"],\"sortIndex\": 100}"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEquality() {
        let person1 = create(Person.self, from: liaraJson)
        let person2 = create(Person.self, from: liaraJson)
        XCTAssert(person1 == person2, "Equality not working")
    }

    /// Test Person get methods.
    func testGetOne() {
        _ = create(Person.self, from: liaraJson)
        let liara1 = Person.get(id: "S1.Liara")
        XCTAssert(liara1?.name == "Liara T'soni", "Failed to load by id")
        let liara2 = Person.get(name: "Liara T'soni")
        XCTAssert(liara2?.name == "Liara T'soni", "Failed to load by name")
    }
    
    /// Test Person getAll methods.
    func testGetAll() {
        _ = create(Person.self, from: liaraJson)
        _ = create(Person.self, from: sarenJson)
        _ = create(Person.self, from: kaidanJson)
        let matches1 = Person.getAll()
        XCTAssert(matches1.count == 3, "Failed to get all persons")
        let matches2 = Person.getAll(likeName: "ar")
        XCTAssert(matches2.count == 2, "Failed to get all persons by name")
    }
    
    /// Test Person sort method.
    func testSort() {
        _ = create(Person.self, from: liaraJson)
        _ = create(Person.self, from: sarenJson)
        _ = create(Person.self, from: kaidanJson)
        // sort by name
        let matches1 = Person.getAll().sorted(by: Person.sort)
        XCTAssert(matches1[0].id == "S1.Kaidan", "Failed to sort Kaidan correctly")
        XCTAssert(matches1[1].id == "S1.Liara", "Failed to sort Liara correctly")
        XCTAssert(matches1[2].id == "E1.Saren", "Failed to sort Saren correctly")
    }
    
    /// Test Person love interest actions.
    func testLoveInterest() {
        initializeCurrentGame(gender: .male) // needed for saving with game uuid & love interest availability
        
        // - verify signal is fired
        let expectationDecisionLoved = expectation(description: "Decision on change triggered")
        Decision.onChange.subscribe(on: self) { (changed: (id: String, object: Decision?)) in
            if changed.id == "D1.LoveLiara",
                let decision = changed.object ?? Decision.get(id: changed.id),
                decision.isSelected {
                expectationDecisionLoved.fulfill()
            }
        }
        
        _ = create(Person.self, from: liaraJson)
        _ = create(Person.self, from: kaidanJson)
        _ = create(Person.self, from: sarenJson)
        var decision = create(Decision.self, from: loveInterestDecisionJson)
        let liara1 = Person.get(id: "S1.Liara")
        let kaidan1 = Person.get(id: "S1.Kaidan")
        let saren1 = Person.get(id: "E1.Saren")
        XCTAssert(liara1?.isAvailableLoveInterest == true, "Reported incorrect love interest availability (interest found)")
        XCTAssert(kaidan1?.isAvailableLoveInterest == false, "Reported incorrect love interest availability (wrong gender)")
        XCTAssert(saren1?.isAvailableLoveInterest == false, "Reported incorrect love interest availability (no interest)")
        XCTAssert(liara1?.isLoveInterest == false, "Reported incorrect love interest (not selected)")
        decision?.change(isSelected: true, isSave: true)
        let liara2 = Person.get(id: "S1.Liara")
        XCTAssert(liara2?.isLoveInterest == true, "Reported incorrect love interest (selected)")
        
        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        Decision.onChange.cancelSubscription(for: self)
    }
    
    /// Test Person game version variations
    func testGetByGameVersion() {
        initializeCurrentGame() // needed for game version
        initializeGameVersionEvents()
        _ = create(Person.self, from: liaraJson)
        _ = create(Person.self, from: sarenJson)
        let liara1 = Person.get(id: "S1.Liara")
        XCTAssert(liara1?.personType == .squad, "Failed to load correct game version")
        let liara2 = Person.get(id: "S1.Liara", gameVersion: .game2)
        XCTAssert(liara2?.personType == .associate, "Failed to load correct game version")
        let liara3 = Person.getAllAssociates(gameVersion: .game2).first
        XCTAssert(liara3?.personType == .associate, "Failed to load correct game 2 associates")
        let saren1 = Person.get(id: "E1.Saren", gameVersion: .game2)
        XCTAssert(saren1?.isAvailable == false, "Failed to change game version availability")
        XCTAssert(saren1?.isAvailableInGame(.game1) == true, "Failed to report correct game version availability")
    }
}
