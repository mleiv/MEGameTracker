//
//  Change20170305.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/5/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

import Foundation
import CoreData

public struct Change20170305: CoreDataMigrationType {
	typealias MoralityIdMap = (fromId: String, toId: String)
	typealias MoralityMissionMap = (fromMissionId: String, toMissionId: String, ids: [MoralityIdMap])
	let mapMoralities: [MoralityMissionMap] = [(
		fromMissionId: "A2.L.Miranda",
		toMissionId: "A2.Convo.Miranda",
		ids: [
			(fromId: "A2.L.Miranda.P1", toId: "A2.Convo.Miranda.P30"),
			(fromId: "A2.L.Miranda.P14", toId: "A2.Convo.Miranda.P40"),
			(fromId: "A2.L.Miranda.P15", toId: "A2.Convo.Miranda.P41"),
		]
	), (
		fromMissionId: "A2.L.Mordin",
		toMissionId: "A2.Convo.Mordin",
		ids: [
			(fromId: "A2.L.Mordin.P1", toId: "A2.Convo.Mordin.P30"),
			(fromId: "A2.L.Mordin.R1", toId: "A2.Convo.Mordin.R30"),
		]
	), (
		fromMissionId: "A2.L.Jacob",
		toMissionId: "A2.Convo.Jacob",
		ids: [
			(fromId: "A2.L.Jacob.P1A", toId: "A2.Convo.Jacob.P30A"),
			(fromId: "A2.L.Jacob.P1B", toId: "A2.Convo.Jacob.P30A"),
			(fromId: "A2.L.Jacob.R1", toId: "A2.Convo.Jacob.R30"),
			(fromId: "A2.L.Jacob.R2", toId: "A2.Convo.Jacob.R31"),
			(fromId: "A2.L.Jacob.P3", toId: "A2.Convo.Jacob.P32"),
			(fromId: "A2.L.Jacob.P14", toId: "A2.Convo.Jacob.P40"),
			(fromId: "A2.L.Jacob.R14", toId: "A2.Convo.Jacob.R40"),
			(fromId: "A2.L.Jacob.R15", toId: "A2.Convo.Jacob.R41"),
			(fromId: "A2.L.Jacob.R16", toId: "A2.Convo.Jacob.R42"),
			(fromId: "A2.L.Jacob.P17", toId: "A2.Convo.Jacob.P43"),
			(fromId: "A2.L.Jacob.R17", toId: "A2.Convo.Jacob.R43"),
		]
	), (
		fromMissionId: "M3.0.Citadel1",
		toMissionId: "A3.Convo.C.Chakwas",
		ids: [
			(fromId: "M3.0.Citadel1.PR3", toId: "A3.Convo.C.Chakwas.P1"),
		]
	), (
		fromMissionId: "M3.0.Citadel1",
		toMissionId: "A3.Convo.C.Michel",
		ids: [
			(fromId: "M3.0.Citadel1.P4", toId: "A3.Convo.C.Michel.P2"),
			(fromId: "M3.0.Citadel1.R4", toId: "A3.Convo.C.Michel.R2"),
		]
	), (
		fromMissionId: "M3.0.Citadel1",
		toMissionId: "A3.Convo.A.Bailey",
		ids: [
			(fromId: "M3.0.Citadel1.P6", toId: "A3.Convo.A.Bailey.P1"),
			(fromId: "M3.0.Citadel1.R6", toId: "A3.Convo.A.Bailey.R1"),
		]
	), (
		fromMissionId: "M3.0.Citadel1",
		toMissionId: "A3.Convo.A.AlJilani",
		ids: [
			(fromId: "M3.0.Citadel1.P9", toId: "A3.Convo.A.AlJilani.P1"),
			(fromId: "M3.0.Citadel1.R9", toId: "A3.Convo.A.AlJilani.R1"),
		]
	), (
		fromMissionId: "M3.0.Citadel1",
		toMissionId: "A3.Convo.S.Vega",
		ids: [
			(fromId: "M3.0.Citadel1.PR10", toId: "A3.Convo.S.Vega.PR0"),
		]
	)]
	/// Correct some changes ids
	public func run() {
		// only run if prior bad data may have been saved
		guard App.current.lastBuild > 0 else { return }

		for mapData in mapMoralities {
			for var fromMission in Mission.getAllExisting(ids: [mapData.fromMissionId], gameSequenceUuid: nil) {
				if var toMission = Mission.get(id: mapData.toMissionId) {
					let fromIds = fromMission.selectedConversationRewards
					guard !fromIds.isEmpty else { continue }
					for idMapData in mapData.ids {
						if fromIds.contains(idMapData.fromId) {
							fromMission.generalData.conversationRewards.unsetSelectedId(idMapData.fromId)
							toMission.generalData.conversationRewards.setSelectedId(idMapData.toId)
						}
					}
					_ = fromMission.save()
					_ = toMission.save()
				}
			}
		}

		specialCaseAshleyKaidan()
	}

	private func specialCaseAshleyKaidan() {
		let fromMissionId = "M3.0.Citadel1"
		let toMissionIdAshley = "A3.Convo.S.Ashley"
		let toMissionIdKaidan = "A3.Convo.S.Kaidan"
		let fromId = "M3.0.Citadel1.PR5"
		let toIdAshley = "A3.Convo.S.Ashley.P1"
		let toIdKaidan = "A3.Convo.S.Kaidan.P1"

		for var fromMission in Mission.getAllExisting(ids: [fromMissionId], gameSequenceUuid: nil) {
			let decision = Decision.get(id: "D1.Ashley", gameSequenceUuid: fromMission.gameSequenceUuid)
			let toMissionId = decision?.isSelected == true ? toMissionIdAshley : toMissionIdKaidan
			let toId = decision?.isSelected == true ? toIdAshley : toIdKaidan
			if var toMission = Mission.get(id: toMissionId) {
				let fromIds = fromMission.selectedConversationRewards
				guard !fromIds.isEmpty else { continue }
				if fromIds.contains(fromId) {
					fromMission.generalData.conversationRewards.unsetSelectedId(fromId)
					toMission.generalData.conversationRewards.setSelectedId(toId)
				}
				_ = fromMission.save()
				_ = toMission.save()
			}
		}
	}
}
