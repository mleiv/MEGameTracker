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

	// swiftlint:disable line_length

	let json1 = "[{\"set\":{\"isExclusiveSet\":true,\"context\":\"Speaking to Joker and Kaidan before Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P1\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"I agree.\\\"\"},{\"id\":\"M1.1Prologue.R1\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Cut the chatter\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Speaking to Jenkins and Dr. Chakwas before Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P2\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Relax, Jenkins.\\\"\"},{\"id\":\"M1.1Prologue.R2\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Part of the job, Doc.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After Jenkins dies on Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P3\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"He deserves a burial.\\\"\"},{\"id\":\"M1.1Prologue.R3\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Forget about him.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After encountering Ashley for the first time on Eden Prime\",\"options\":[{\"id\":\"M1.1Prologue.P4\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Are you okay?\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Asking Ashley about her squad\",\"options\":[{\"id\":\"M1.1Prologue.P5\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"Don\'t blame yourself.\\\"\"},{\"id\":\"M1.1Prologue.R5\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"You abandoned them.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"After telling Ashley to stay behind\",\"options\":[{\"id\":\"M1.1Prologue.R6\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"Fine, come with us.\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P7\",\"type\":\"Paragon\",\"value\":2,\"context\":\"After finding Dr. Warren and Manuel at the Dig Site\",\"trigger\":\"\\\"You\'re safe.\\\"\"},{\"id\":\"M1.1Prologue.R7\",\"type\":\"Renegade\",\"value\":9,\"context\":\"After asking Dr. Warren about her assistant\",\"trigger\":\"\\\"I can shut him up.\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P8\",\"type\":\"Paragon\",\"value\":2,\"context\":\"Meeting Cole and the Colonists at the Dig Site\",\"trigger\":\"\\\"It\'s safe.\\\"\"},{\"id\":\"M1.1Prologue.R8\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Cole (requires 1 Intimidate)\",\"trigger\":\"\\\"You\'re holding out on me.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"options\":[{\"id\":\"M1.1Prologue.P9\",\"type\":\"Paragon\",\"value\":2,\"context\":\"*_Charm_* Cole (requires 2 Charm)\",\"trigger\":\"\\\"He may know something.\\\"\"},{\"id\":\"M1.1Prologue.R9\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Cole (requires 2 Intimidate)\",\"trigger\":\"\\\"Is he worth dying for?\\\"\"}]}},{\"set\":{\"options\":[{\"id\":\"M1.1Prologue.P10\",\"type\":\"Paragon\",\"value\":2,\"context\":\"Talking to Powell at the Spaceport (after getting Powell\'s name from Cole)\",\"trigger\":\"\\\"Let it go, Williams.\\\"\"},{\"id\":\"M1.1Prologue.R10\",\"type\":\"Renegade\",\"value\":2,\"context\":\"*_Intimidate_* Powell (requires 1 Intimidate)\",\"trigger\":\"\\\"You\'re lying!\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"options\":[{\"set\":{\"isExclusiveSet\":true,\"context\":\"Talking to Kaidan after the mission\",\"options\":[{\"id\":\"M1.1Prologue.P11\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"You helped.\\\"\"},{\"id\":\"M1.1Prologue.R11\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"The mission failed.\\\"\"}]}},{\"set\":{\"isExclusiveSet\":true,\"context\":\"Talking to Ashley after the mission\",\"options\":[{\"id\":\"M1.1Prologue.P12\",\"type\":\"Paragon\",\"value\":2,\"trigger\":\"\\\"You helped.\\\"\"},{\"id\":\"M1.1Prologue.R12\",\"type\":\"Renegade\",\"value\":2,\"trigger\":\"\\\"The mission failed.\\\"\"}]}}]}\t\t}]"

	let json2 = "[{\"set\": {\"context\": \"Talking down Ashley\\/Kaidan\",\"isExclusiveSet\": true,\"options\": [{\"set\": {\"context\": \"100% Trust\",\"options\": [{\"set\": {\"isExclusiveSet\": true,\"options\": [{\"set\": {\"context\": \"\\\"You\'re making a mistake.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.P2\",\"type\": \"Paragon\",\"value\": 5,\"context\": \"*Paragon Interrupt*\",\"trigger\": \"Lower guns.\"}]}}, {\"set\": {\"context\": \"\\\"Step aside.\\\" or \\\"I\'ve come for Udina.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.R2\",\"type\": \"Renegade\",\"value\": 5,\"context\": \"*Renegade Interrupt*\",\"trigger\": \"Lower guns.\"}]}}]}}, {\"id\": \"M3.2.Citadel2.PR2\",\"type\": \"Paragade\",\"value\": 15,\"trigger\": \"(Completing the conversation.)\"}]}}, {\"set\": {\"context\": \"25-75% Trust\",\"options\": [{\"set\": {\"isExclusiveSet\": true,\"options\": [{\"set\": {\"context\": \"\\\"Trust me.\\\" or \\\"You\'re making a mistake.\\\" or \\\"Don\'t get paranoid on me.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.P10\",\"type\": \"Paragon\",\"value\": 5,\"context\": \"*Paragon Interrupt*\",\"trigger\": \"Lower guns.\"}]}}, {\"set\": {\"context\": \"\\\"Step aside. Now.\\\" or \\\"Sure I do.\\\" or \\\"I\'ve come for Udina.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.R10\",\"type\": \"Renegade\",\"value\": 5,\"context\": \"*Renegade Interrupt*\",\"trigger\": \"Lower guns.\"}]}}]}}, {\"set\": {\"isExclusiveSet\": true,\"options\": [{\"id\": \"M3.2.Citadel2.P11\",\"type\": \"Paragon\",\"value\": 15,\"context\": \"*_Charm Ashley\\/Kaidan_* (requires 50-75% Trust or Interrupt above)\",\"trigger\": \"\\nAshley: \\\"Trust me.\\\" or \\\"You\'re better than this.\\\" \\nKaidan: \\\"You first.\\\" or \\\"I wouldn\'t kill the Council.\\\"\"}, {\"id\": \"M3.2.Citadel2.R11\",\"type\": \"Renegade\",\"value\": 15,\"context\": \"*_Intimidate Ashley\\/Kaidan_* (requires 50-75% Trust or Interrupt above)\",\"trigger\": \"\\nAshley: \\\"You can\'t win.\\\" or \\\"You forget why we\'re here.\\\" \\nKaidan: \\\"I won\'t.\\\" or \\\"This is bigger than you.\\\"\"}, {\"set\": {\"context\": \"\\\"Don\'t make me kill you.\\\" or \\\"I wish you were right.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.R12\",\"type\": \"Renegade\",\"value\": 5,\"context\": \"*Renegade Interrupt*\",\"trigger\": \"Shoot Ashley\\/Kaidan.\"}]}}]}}]}}, {\"set\": {\"context\": \"0% Trust\",\"isExclusiveSet\": true,\"options\": [{\"set\": {\"context\": \"\\\"Calm down.\\\" or \\\"I don\'t think so.\\\"\",\"options\": [{\"id\": \"M3.2.Citadel2.P20\",\"type\": \"Paragon\",\"value\": 5,\"context\": \"*Paragon Interrupt*\",\"trigger\": \"Lower guns.\"}, {\"id\": \"M3.2.Citadel2.R20A\",\"type\": \"Renegade\",\"value\": 5,\"context\": \"*Renegade Interrupt*\",\"trigger\": \"Lower guns.\"}, {\"id\": \"M3.2.Citadel2.R20B\",\"type\": \"Renegade\",\"value\": 5,\"context\": \"*Renegade Interrupt*\",\"trigger\": \"Shoot Ashley\\/Kaidan.\"}]}}]}}]}}]"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testHierarchy1() {
        guard let data = json1.data(using: .utf8),
            let rewards = try? CoreDataManager.current.decoder.decode(ConversationRewards.self, from: data)
        else {
			XCTAssert(false, "Could not initialize ConversationRewards base")
			return
		}
		let flattenedRewards = rewards.points.flatMap({ self.flatten(rewards: $0) })
		XCTAssert(flattenedRewards[0] == "- -  M1.1Prologue.P1", "Hierarchy incorrect")
		XCTAssert(flattenedRewards[21] == "- - -  M1.1Prologue.R12", "Hierarchy incorrect")
	}

	func testHierarchy2() {
        guard let data = json2.data(using: .utf8),
            let rewards = try? CoreDataManager.current.decoder.decode(ConversationRewards.self, from: data)
		else {
			XCTAssert(false, "Could not initialize ConversationRewards base")
			return
		}
		let flattenedRewards = rewards.points.flatMap({ self.flatten(rewards: $0) })
		XCTAssert(flattenedRewards[0] == "- - - - -  M3.2.Citadel2.P2", "Hierarchy incorrect")
		XCTAssert(flattenedRewards[10] == "- - - -  M3.2.Citadel2.R20B", "Hierarchy incorrect")
	}

	func testFlatten1() {
		guard let data = json1.data(using: .utf8),
            let rewards = try? CoreDataManager.current.decoder.decode(ConversationRewards.self, from: data)
		else {
			XCTAssert(false, "Could not initialize ConversationRewards base")
			return
		}
		let flattenedRewards = rewards.flatRows()
		XCTAssert(flattenedRewards.count == 15, "Row count incorrect")
		XCTAssert(flattenedRewards[0].commonContext == "Speaking to Joker and Kaidan before Eden Prime", "Flatten incorrect")
		XCTAssert(flattenedRewards[0].options.count == 2, "Flatten incorrect")
		XCTAssert(flattenedRewards[0].options.first?.id == "M1.1Prologue.P1", "Flatten incorrect")
		XCTAssert(flattenedRewards[14].commonContext == "Talking to Ashley after the mission", "Flatten incorrect")
		XCTAssert(flattenedRewards[14].options.count == 2, "Flatten incorrect")
		XCTAssert(flattenedRewards[14].options.first?.id == "M1.1Prologue.P12", "Flatten incorrect")
//		print(flattenedRewards.flatMap({ "- \((0..<$0.level)
//			.reduce(""){ s,_ in s + "- " }) \($0.commonContext) \($0.options.count)" }).joined(separator: "\n"))
	}

	func testFlatten2() {
        guard let data = json2.data(using: .utf8),
            let rewards = try? CoreDataManager.current.decoder.decode(ConversationRewards.self, from: data)
		else {
			XCTAssert(false, "Could not initialize ConversationRewards base")
			return
		}
		let flattenedRewards = rewards.flatRows()
		XCTAssert(flattenedRewards.count == 16, "Row count incorrect")
		XCTAssert(flattenedRewards[0].commonContext == "Talking down Ashley/Kaidan", "Flatten incorrect")
		XCTAssert(flattenedRewards[1].commonContext == "100% Trust", "Flatten incorrect")
		XCTAssert(flattenedRewards[2].commonContext == "\"You\'re making a mistake.\"", "Flatten incorrect")
		XCTAssert(flattenedRewards[15].options.first?.trigger == "Shoot Ashley/Kaidan.", "Flatten incorrect")
//		print(flattenedRewards.flatMap({ "- \((0..<$0.level)
//			.reduce(""){ s,_ in s + "- " }) \($0.commonContext) \($0.options.count)" }).joined(separator: "\n"))
	}

	private func flatten(rewards: ConversationRewardSet, level: Int = 0) -> [String] {
		var list: [String] = []
		if let point = rewards.point {
			list.append("- \((0..<level).reduce("") { s, _ in s + "- " }) \(point.id)")
		}
		for reward in rewards.subset ?? [] {
			list += flatten(rewards: reward, level: level + 1)
		}
		return list
	}

}
