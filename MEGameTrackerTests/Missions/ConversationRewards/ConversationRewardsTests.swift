//
//  ConversationRewardsTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 5/15/2016.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class ConversationRewardsTests: MEGameTrackerTests {

    let json1 = "[{\"set\":{\"isExclusiveSet\":true,\"context\":\"Speaking to Joker and Kaidan before Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P1\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"I agree.\\\"\"},{\"id\":\"M1.1Prologue.R1\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Cut the chatter\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Speaking to Jenkins and Dr. Chakwas before Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P2\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Relax, Jenkins.\\\"\"},{\"id\":\"M1.1Prologue.R2\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Part of the job, Doc.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After Jenkins dies on Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P3\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"He deserves a burial.\\\"\"},{\"id\":\"M1.1Prologue.R3\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Forget about him.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After encountering Ashley for the first time on Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P4\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Are you okay?\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Asking Ashley about her squad\",\"options\":[{\"id\":\"M1.1Prologue.P5\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Don\'t blame yourself.\\\"\"},{\"id\":\"M1.1Prologue.R5\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"You abandoned them.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After telling Ashley to stay behind\",\"options\":[{\"id\":\"M1.1Prologue.R6\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Fine, come with us.\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P7\",\"type\":\"Paragon\",\"value\":2,\"context\":\"After finding Dr. Warren and Manuel at the Dig Site\",\"trigger\":\"\\\"You\'re safe.\\\"\"},{\"id\":\"M1.1Prologue.R7\",\"type\":\"Renegade\",\"value\":9,\"context\":\"After asking Dr. Warren about her assistant\",\"trigger\":\"\\\"I can shut him up.\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P8\",\"type\":\"Paragon\",\"value\":2,\"context\":\"Meeting Cole and the Colonists at the Dig Site\",\"trigger\":\"\\\"It\'s safe.\\\"\"},{\"id\":\"M1.1Prologue.R8\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Cole (requires 1 Intimidate)\",\"trigger\":\"\\\"You\'re holding out on me.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"options\":[{\"id\":\"M1.1Prologue.P9\",\"type\":\"Paragon\",\"value\":2,\"context\":\"*_Charm_* Cole (requires 2 Charm)\",\"trigger\":\"\\\"He may know something.\\\"\"},{\"id\":\"M1.1Prologue.R9\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Cole (requires 2 Intimidate)\",\"trigger\":\"\\\"Is he worth dying for?\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P10\",\"type\":\"Paragon\",\"value\":2,\"context\":\"Talking to Powell at the Spaceport (after getting Powell\'s name from Cole)\",\"trigger\":\"\\\"Let it go, Williams.\\\"\"},{\"id\":\"M1.1Prologue.R10\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Powell (requires 1 Intimidate)\",\"trigger\":\"\\\"You\'re lying!\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"options\":[{\"set\":{\"isExclusiveSet\":true,\"context\":\"Talking to Kaidan after the mission\",\"options\":[{\"id\":\"M1.1Prologue.P11\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"You helped.\\\"\"},{\"id\":\"M1.1Prologue.R11\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"The mission failed.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Talking to Ashley after the mission\",\"options\":[{\"id\":\"M1.1Prologue.P12\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"You helped.\\\"\"},{\"id\":\"M1.1Prologue.R12\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"The mission failed.\\\"\"}]}}]}\t\t}]"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testHierarchy() {
        guard let rewards = ConversationRewards(serializedString: json1)
        else {
            XCTAssert(false, "Could not initialize DataMission base")
            return
        }
        let flattenedRewards = rewards.points.flatMap({ self.flatten(rewards: $0) })
        XCTAssert(flattenedRewards[0] == "- -  M1.1Prologue.P1", "Hierarchy incorrect")
        XCTAssert(flattenedRewards[21] == "- - -  M1.1Prologue.R12", "Hierarchy incorrect")
    }
    
    func testFlatten() {
        guard let rewards = ConversationRewards(serializedString: json1)
        else {
            XCTAssert(false, "Could not initialize DataMission base")
            return
        }
        _ = rewards.flatRows()
//        print(flattenedRewards.flatMap({ "- \((0..<$0.level).reduce(""){ s,_ in s + "- " }) \($0.commonContext) \($0.options.count)" }).joined(separator: "\n"))
    }
    
    private func flatten(rewards: ConversationRewardSet, level: Int = 0) -> [String] {
        var list: [String] = []
        if let point = rewards.point {
            list.append("- \((0..<level).reduce(""){ s,_ in s + "- " }) \(point.id)")
        }
        for reward in rewards.subset ?? [] {
            list += flatten(rewards: reward, level: level + 1)
        }
        return list
    }
    
}
