//
//  Change20190527.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/19.
//  Copyright © 2019 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct Change20190527: CoreDataMigrationType {
    typealias IdMap = (fromId: String, toId: String)
    typealias MoralityMissionMap = (fromMissionId: String, toMissionId: String, ids: [IdMap])

    let mapMoralities: [MoralityMissionMap] = [(
        fromMissionId: "A3.ArdatYakshiMonastery",
        toMissionId: "A3.ArdatYakshiMonastery",
        ids: [
            (fromId: "A3.ArdatYakshiMonastery.P4", toId: "A3.ArdatYakshiMonastery.R4"),
        ]
    ), (
        fromMissionId: "A1.N.Espionage",
        toMissionId: "A1.N.Espionage",
        ids: [
            (fromId: "A1.N.Espionage.2.P1", toId: "A1.N.Espionage.2.P1.Dup1"),
        ]
    ), (
        fromMissionId: "A1.N.Quarantine",
        toMissionId: "A1.N.Quarantine",
        ids: [
            (fromId: "A1.N.Espionage.2.P1", toId: "A1.N.Espionage.2.P1.Dup2"),
        ]
    ), (
        fromMissionId: "A2.C.FalsePositives",
        toMissionId: "A2.C.FalsePositives",
        ids: [
            (fromId: "A2.C.FalsePositives.P2", toId: "A2.C.FalsePositives.P5"),
            (fromId: "A2.C.CrimeInProgress.P2", toId: "A2.C.FalsePositives.R2"),
            (fromId: "A2.C.CrimeInProgress.P1B", toId: "A2.C.FalsePositives.P1B"),
        ]
    ), (
        fromMissionId: "A2.L.Thane",
        toMissionId: "A2.L.Thane",
        ids: [
            (fromId: "A2.L.Thane.R11A", toId: "A2.L.Thane.R11A.Dup1"),
        ]
    ), (
        fromMissionId: "A3.GethFighterSquadrons",
        toMissionId: "A3.GethFighterSquadrons",
        ids: [
            (fromId: "A3.GethFighterSquadrons.P5A", toId: "A3.GethFighterSquadrons.P5A.Dup1"),
            (fromId: "A3.GethFighterSquadrons.R5A", toId: "A3.GethFighterSquadrons.R5A.Dup1"),
            (fromId: "A3.GethFighterSquadrons.P5B", toId: "A3.GethFighterSquadrons.P5B.Dup1"),
            (fromId: "A3.GethFighterSquadrons.R5B", toId: "A3.GethFighterSquadrons.R5B.Dup1"),
            (fromId: "A3.GethFighterSquadrons.P6", toId: "A3.GethFighterSquadrons.P6.Dup1"),
            (fromId: "A3.GethFighterSquadrons.R6A", toId: "A3.GethFighterSquadrons.R6A.Dup1"),
            (fromId: "A3.GethFighterSquadrons.R6B", toId: "A3.GethFighterSquadrons.R6B.Dup1"),
        ]
    ), (
        fromMissionId: "A3.AdmiralKoris",
        toMissionId: "A3.AdmiralKoris",
        ids: [
            (fromId: "A3.GethFighterSquadrons.P5A", toId: "A3.GethFighterSquadrons.P5A.Dup2"),
            (fromId: "A3.GethFighterSquadrons.R5A", toId: "A3.GethFighterSquadrons.R5A.Dup2"),
            (fromId: "A3.GethFighterSquadrons.P5B", toId: "A3.GethFighterSquadrons.P5B.Dup2"),
            (fromId: "A3.GethFighterSquadrons.R5B", toId: "A3.GethFighterSquadrons.R5B.Dup2"),
            (fromId: "A3.GethFighterSquadrons.P6", toId: "A3.GethFighterSquadrons.P6.Dup2"),
            (fromId: "A3.GethFighterSquadrons.R6A", toId: "A3.GethFighterSquadrons.R6A.Dup2"),
            (fromId: "A3.GethFighterSquadrons.R6B", toId: "A3.GethFighterSquadrons.R6B.Dup2"),
        ]
    ), (
        fromMissionId: "A3.TurianPlatoon",
        toMissionId: "A3.TurianPlatoon",
        ids: [
            (fromId: "A3.TurianPlatoon.P10", toId: "A3.TurianPlatoon.P10.Dup1"),
            (fromId: "A3.TurianPlatoon.R10", toId: "A3.TurianPlatoon.R10.Dup1"),
            (fromId: "A3.TurianPlatoon.P11", toId: "A3.TurianPlatoon.P11.Dup1"),
            (fromId: "A3.TurianPlatoon.R11", toId: "A3.TurianPlatoon.R11.Dup1"),
        ]
    ), (
        fromMissionId: "A3.KroganTeam",
        toMissionId: "A3.KroganTeam",
        ids: [
            (fromId: "A3.TurianPlatoon.P10", toId: "A3.TurianPlatoon.P10.Dup2"),
            (fromId: "A3.TurianPlatoon.R10", toId: "A3.TurianPlatoon.R10.Dup2"),
            (fromId: "A3.TurianPlatoon.P11", toId: "A3.TurianPlatoon.P11.Dup2"),
            (fromId: "A3.TurianPlatoon.R11", toId: "A3.TurianPlatoon.R11.Dup2"),
        ]
    ), (
        fromMissionId: "A2.Convo.OmegaMarket",
        toMissionId: "A2.Convo.OmegaMarket",
        ids: [
            (fromId: "A2.Convo.SerriceTechnology.P1", toId: "A2.Convo.OmegaMarket.P1"),
            (fromId: "A2.Convo.SerriceTechnology.R1", toId: "A2.Convo.OmegaMarket.R1"),
        ]
    ), (
        fromMissionId: "A3.Convo.OC.Hospital1",
        toMissionId: "A3.Convo.OC.Hospital2",
        ids: [
            (fromId: "A3.Convo.OC.Hospital1.PR5", toId: "A3.Convo.OC.Hospital2.PR5"),
        ]
    ), (
        fromMissionId: "A3.Convo.C.Mordin",
        toMissionId: "A3.Convo.A.Mordin",
        ids: [
            (fromId: "A3.Convo.C.Mordin.P1", toId: "A3.Convo.A.Mordin.P1"),
            (fromId: "A3.Convo.C.Mordin.R1", toId: "A3.Convo.A.Mordin.R1"),
        ]
    ), (
        fromMissionId: "A3.Convo.C.Joker",
        toMissionId: "A3.Convo.C.Joker",
        ids: [
            (fromId: "A3.Convo.C.Joker.PR10", toId: "A3.Convo.C.Joker.PR10.Dup1"),
        ]
    ), (
        fromMissionId: "A3.Convo.S.Garrus",
        toMissionId: "A3.Convo.S.Garrus",
        ids: [
            (fromId: "A3.Convo.C.Joker.PR10", toId: "A3.Convo.C.Joker.PR10.Dup2"),
        ]
    )]

    let mapMissions: [IdMap] = [
        (fromId: "A3.Convo.C.Cortez.7", toId: "A3.Convo.C.Cortez.8a"),
        (fromId: "A3.Convo.C.Cortez.8", toId: "A3.Convo.C.Cortez.7a"),
        (fromId: "A3.Convo.C.Mordin", toId: "A3.Convo.A.Mordin"),
        (fromId: "A3.Convo.C.Mordin.1", toId: "A3.Convo.A.Mordin.1"),
        (fromId: "A3.Convo.C.Mordin.2", toId: "A3.Convo.A.Mordin.2"),
        (fromId: "A3.Convo.C.Mordin.3", toId: "A3.Convo.A.Mordin.3"),
        (fromId: "DLC3.Citadel2.10", toId: "DLC3.Citadel3"),
        (fromId: "DLC3.Citadel2.10.1", toId: "DLC3.Citadel3.02"),
        (fromId: "DLC3.Citadel2.10.2", toId: "DLC3.Citadel3.03"),
        (fromId: "DLC3.Citadel2.10.3", toId: "DLC3.Citadel3.01"),
        (fromId: "DLC3.Citadel2.10.4", toId: "DLC3.Citadel3.06"),
        (fromId: "DLC3.Citadel2.10.5", toId: "DLC3.Citadel3.04"),
        (fromId: "DLC3.Citadel2.10.6", toId: "DLC3.Citadel3.08"),
        (fromId: "DLC3.Citadel2.10.7", toId: "DLC3.Citadel3.05"),
        (fromId: "DLC3.Citadel2.10.8", toId: "DLC3.Citadel3.07"),
        (fromId: "DLC3.Citadel2.10.9", toId: "DLC3.Citadel3.10"),
        (fromId: "DLC3.Citadel2.10.9.1", toId: "DLC3.Citadel3.10.1"),
        (fromId: "DLC3.Citadel2.10.9.2", toId: "DLC3.Citadel3.10.2"),
        (fromId: "DLC3.Citadel2.10.9.3", toId: "DLC3.Citadel3.10.3"),
        (fromId: "DLC3.Citadel2.10.10", toId: "DLC3.Citadel3.09"),
        (fromId: "DLC3.Citadel2.5.Kaidan", toId: "DLC3.Citadel2.6.Kaidan"),
        (fromId: "DLC3.Citadel2.5.Ashley", toId: "DLC3.Citadel2.6.Ashley"),
        (fromId: "DLC3.Citadel2.6.Jacob", toId: "DLC3.Citadel2.5.Jacob"),
        (fromId: "DLC3.Citadel2.6.Thane", toId: "DLC3.Citadel2.5.Thane"),
    ]

    let mapItems: [IdMap] = [
        (fromId: "DLC3.Omega2B.I.1", toId: "A3.Aria2.I.1"),
    ]


    /// Correct some changes ids
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
        correctMovedMissions()
        remapMoralityChoices()
        correctRenamedItem()
        cleanup()
    }

    private func createIfMissingMission(id: String, gameVersion: GameVersion) -> Mission? {
        if let mission = Mission.get(id: id) {
            return mission
        }
        var dataMission = DataMission(id: id)
        dataMission.gameVersion = gameVersion
        _ = dataMission.save()
        return Mission.get(id: id)
    }

    private func cleanup() {
        let oldMissionIds = mapMissions.map { $0.fromId }
        _ = DataMission.deleteAll(ids: oldMissionIds)
        Mission.getAll(ids: oldMissionIds).forEach { var m = $0; _ = m.delete() }
        let oldItemIds = mapItems.map { $0.fromId }
        _ = DataItem.deleteAll(ids: oldItemIds)
        Item.getAll(ids: oldItemIds).forEach { var i = $0; _ = i.delete() }
    }

    private func correctMovedMissions() {
        // load the old missions.
        for mission in mapMissions {
            guard let fromMission = Mission.getExisting(
                id: mission.fromId,
                gameSequenceUuid: nil
                ) else { continue }
            var newMission = fromMission
            newMission.migrateId(id: mission.toId)
            _ = newMission.save()
        }
    }

    private func remapMoralityChoices() {
        for mapData in mapMoralities {
            for var fromMission in Mission.getAllExisting(
                ids: [mapData.fromMissionId],
                gameSequenceUuid: nil
                ) {
                    if var toMission = createIfMissingMission(id: mapData.toMissionId, gameVersion: fromMission.gameVersion) {
                        let fromIds = fromMission.selectedConversationRewards
                        guard !fromIds.isEmpty else { continue }
                        var selectedConversationRewards: [String] = []
                        for idMapData in mapData.ids {
                            if fromIds.contains(idMapData.fromId) {
                                selectedConversationRewards.append(idMapData.toId)
                                fromMission.generalData.conversationRewards
                                    .unsetSelectedId(idMapData.fromId)
                            }
                        }
                        toMission.overrideSelectedConversationRewards(selectedConversationRewards)
                        _ = fromMission.save()
                        _ = toMission.save()
                    }
            }
        }
    }

    private func correctRenamedItem() {
        // load the old items.
        for item in mapItems {
            guard let fromItem = Item.getExisting(
                id: item.fromId,
                gameSequenceUuid: nil
                ) else { continue }
            var newItem = fromItem
            newItem.migrateId(id: item.toId)
            _ = newItem.save()
        }
    }
}
