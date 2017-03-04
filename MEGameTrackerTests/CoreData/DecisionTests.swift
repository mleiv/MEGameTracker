//
//  DecisionTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class DecisionTests: MEGameTrackerTests {

    let fistJson = "{\"id\": \"D1.Fist\",\"gameVersion\": \"1\",\"name\": \"Fist spared\",\"description\": \"If you don\'t bring Wrex along on [megametracker:\\/\\/mission?id=M1.ExposeSaren.2], you can leave Fist alive. Then you can run into him again in Game 2 at Afterlife on Omega.\",\"sortIndex\": 10}"

    let ritaJson = "{\"id\": \"D1.Rita\",\"gameVersion\": \"1\",\"name\": \"Helped Jenna in Chora\'s Den\",\"description\": \"If you help Jenna in [Citadel: Rita\'s Sister|megametracker:\\/\\/mission?id=A1.C1.RitasSister], she can save Conrad Verner\'s life in Game 3.\",\"sortIndex\": 11}"

    let conradJson = "{\"id\": \"D1.Conrad\",\"gameVersion\": \"1\",\"name\": \"Set Conrad Verner straight (Game 1)\",\"description\": \"Charm or Intimidate Conrad into giving up his idea of being a hero.\\n\\nIf Shepard helps Conrad in Games 1, 2, and 3, Conrad will save Shepard\'s life in Game 3. His doctoral dissertation could also become a War Asset (see the four requirements here: [https:\\/\\/www.reddit.com\\/r\\/masseffect\\/comments\\/1q8de2\\/dr_conrad_verner\\/]).\",\"sortIndex\": 15}"
    
    let niftuJson = "{\"id\": \"D2.NiftuCal\",\"gameVersion\": \"2\",\"name\": \"Niftu Cal survived his drug trip\",\"description\": \"Shepard prevents Niftu Cal from attacking the Eclipse mercenary stronghold on Illium during [megametracker:\\/\\/mission?id=A2.D.Samara], thereby saving his life.\",\"sortIndex\": 20}"
    
    let saveAshleyJson = "{\"id\": \"D1.Ashley\",\"gameVersion\": \"1\",\"name\": \"Saved Ashley Williams on Virmire\",\"description\": \"If you save Ashley, she will play a key role in Games 2 and 3.\",\"blocksDecisionIds\": [\"D1.Kaidan\"],\"sortIndex\": 203}"

    let saveKaidanJson = "{\"id\": \"D1.Kaidan\",\"gameVersion\": \"1\",\"name\": \"Saved Kaidan Alenko on Virmire\",\"description\": \"If you save Kaidan, he will play a key role in Games 2 and 3.\",\"blocksDecisionIds\": [\"D1.Ashley\"],\"sortIndex\": 203}"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEquality() {
        let decision1 = create(Decision.self, from: fistJson)
        let decision2 = create(Decision.self, from: fistJson)
        XCTAssert(decision1 == decision2, "Equality not working")
    }

    /// Test Decision get methods.
    func testGetOne() {
        _ = create(Decision.self, from: fistJson)
        let fist = Decision.get(id: "D1.Fist")
        XCTAssert(fist?.name == "Fist spared", "Failed to load by id")
    }
    
    /// Test Decision getAll methods.
    func testGetAll() {
        _ = create(Decision.self, from: fistJson)
        _ = create(Decision.self, from: ritaJson)
        _ = create(Decision.self, from: conradJson)
        let decisions = Decision.getAll()
        print(decisions.count)
        XCTAssert(decisions.count == 3, "Failed to get all decisions")
    }
    
    /// Test Decision sort method.
    func testSort() {
        _ = create(Decision.self, from: conradJson)
        _ = create(Decision.self, from: fistJson)
        _ = create(Decision.self, from: ritaJson)
        // sort by id
        let matches = Decision.getAll().sorted(by: Decision.sort)
        XCTAssert(matches[0].id == "D1.Fist", "Failed to sort Fist correctly")
        XCTAssert(matches[1].id == "D1.Rita", "Failed to sort Rita correctly")
        XCTAssert(matches[2].id == "D1.Conrad", "Failed to sort Conrad correctly")
    }
    
    /// Test Decision game version variations
    func testGetByGameVersion() {
        initializeCurrentGame() // needed for game version
        
        _ = create(Decision.self, from: fistJson)
        _ = create(Decision.self, from: ritaJson)
        _ = create(Decision.self, from: niftuJson)
        let matches1 = Decision.getAll(gameVersion: .game1)
        XCTAssert(matches1.count == 2, "Failed to get all game 1 decisions")
        let matches2 = Decision.getAll(gameVersion: .game2)
        XCTAssert(matches2.count == 1, "Failed to get all game 2 decisions")
    }
    
    /// Test Decision change action.
    func testChange() {
        initializeCurrentGame() // needed for saving with game uuid
        
        // - verify signal is fired
        let expectationDecisionOnChange = expectation(description: "Decision on change triggered")
        Decision.onChange.subscribe(on: self) { (changed: (id: String, object: Decision?)) in
            if changed.id == "D1.Fist" {
                expectationDecisionOnChange.fulfill()
            }
        }
        
        var decision = create(Decision.self, from: fistJson)
        XCTAssert(decision?.isSelected == false, "Reported incorrect decision state (selected)")
        decision?.change(isSelected: true, isSave: true)
        let decision2 = Decision.get(id: "D1.Fist")
        XCTAssert(decision2?.isSelected == true, "Reported incorrect decision state (unselected)")
        
        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        Decision.onChange.cancelSubscription(for: self)
    }
    
    /// Test Decision blocking action.
    func testBlocking() {
        initializeCurrentGame() // needed for saving with game uuid
        
        var decision1 = create(Decision.self, from: saveAshleyJson)
        var decision2 = create(Decision.self, from: saveKaidanJson)
        
        // #1 Verify initial state
        XCTAssert(decision1?.isSelected == false, "Reported incorrect decision state (selected)")
        XCTAssert(decision2?.isSelected == false, "Reported incorrect decision state (selected)")
        
        // #2 Save Ashley
        decision1?.change(isSelected: true, isSave: true)
        decision1 = Decision.get(id: "D1.Ashley")
        XCTAssert(decision1?.isSelected == true, "Reported incorrect decision state (unselected)")
        
        // #3 Save Kaidan instead
        
        // - verify signal is fired
        let expectationDecisionOnChange = expectation(description: "Decision on change triggered")
        Decision.onChange.subscribe(on: self) { (changed: (id: String, object: Decision?)) in
            if changed.id == "D1.Ashley",
                let decision = changed.object ?? Decision.get(id: changed.id),
                !decision.isSelected {
                expectationDecisionOnChange.fulfill()
            }
        }
        
        decision2?.change(isSelected: true, isSave: true)
        decision2 = Decision.get(id: "D1.Kaidan")
        XCTAssert(decision2?.isSelected == true, "Reported incorrect decision state (unselected)")
        
        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        Decision.onChange.cancelSubscription(for: self)
        
        // #4 Verify Ashley was changed
        decision1 = Decision.get(id: "D1.Ashley")
        XCTAssert(decision1?.isSelected == false, "Reported incorrect decision state (selected)")
    }
}

