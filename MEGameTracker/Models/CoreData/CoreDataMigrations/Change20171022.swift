//
//  Change20171022.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/5/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct Change20171022: CoreDataMigrationType {
    typealias MoralityIdMap = (fromId: String, toId: String)
    typealias MoralityMissionMap = (fromMissionId: String, toMissionId: String, ids: [MoralityIdMap])

    let mapMoralities: [MoralityMissionMap] = [(
        fromMissionId: "A2.N.SerriceIceBrandy",
        toMissionId: "A2.Convo.Chakwas",
        ids: [
            (fromId: "A2.N.SerriceIceBrandy.P0", toId: "A2.Convo.Chakwas.P0"),
        ]
    ), (
        fromMissionId: "A2.D.Mordin",
        toMissionId: "A2.Convo.Gavorn",
        ids: [
            (fromId: "A2.D.Mordin.P18", toId: "A2.Convo.Gavorn.P0"),
            (fromId: "A2.D.Mordin.R18", toId: "A2.Convo.Gavorn.R0"),
        ]
    ), (
        fromMissionId: "A1.T.VirmirePrisoners",
        toMissionId: "A1.Convo.Virmire.Imness",
        ids: [
            (fromId: "A1.T.VirmirePrisoners.2.P1", toId: "A1.Convo.Virmire.Imness.P1"),
            (fromId: "A1.T.VirmirePrisoners.2.R1", toId: "A1.Convo.Virmire.Imness.R1"),
        ]
    ), (
        fromMissionId: "A1.T.VirmirePrisoners",
        toMissionId: "A1.Convo.Virmire.Others",
        ids: [
            (fromId: "A1.T.VirmirePrisoners.2.P2", toId: "A1.Convo.Virmire.Others.P1"),
            (fromId: "A1.T.VirmirePrisoners.2.R2", toId: "A1.Convo.Virmire.Others.R1"),
        ]
    ), (
        fromMissionId: "A1.T.VirmirePrisoners",
        toMissionId: "A1.Convo.Virmire.Avot",
        ids: [
            (fromId: "A1.T.VirmirePrisoners.1.P1", toId: "A1.Convo.Virmire.Avot.P1"),
            (fromId: "A1.T.VirmirePrisoners.1.R1", toId: "A1.Convo.Virmire.Avot.R1"),
        ]
    ), (
        fromMissionId: "A1.T.StrangeBehavior",
        toMissionId: "A1.Convo.Feros.Blakes",
        ids: [
            (fromId: "A1.T.StrangeBehavior.P1", toId: "A1.Convo.Feros.Blakes.P1"),
            (fromId: "A1.T.StrangeBehavior.R1", toId: "A1.Convo.Feros.Blakes.R1"),
        ]
    ), (
        fromMissionId: "A1.T.StrangeBehavior",
        toMissionId: "A1.Convo.Feros.Newstead",
        ids: [
            (fromId: "A1.T.StrangeBehavior.P2", toId: "A1.Convo.Feros.Newstead.P1"),
            (fromId: "A1.T.StrangeBehavior.R2", toId: "A1.Convo.Feros.Newstead.R1"),
        ]
    ), (
        fromMissionId: "A1.T.UdinaOnFeros",
        toMissionId: "A1.Convo.Citadel.Udina",
        ids: [
            (fromId: "A1.T.UdinaOnFerosP", toId: "A1.Convo.Citadel.Udina.P1"),
            (fromId: "A1.T.UdinaOnFerosR", toId: "A1.Convo.Citadel.Udina.R1"),
        ]
    )]

    let oldMissionIds = [
        "A1.T.VirmirePrisoners",
        "A1.T.VirmirePrisoners.1",
        "A1.T.VirmirePrisoners.2",
        "A1.T.StrangeBehavior",
        "A1.T.StrangeBehavior.1",
        "A1.T.StrangeBehavior.2",
        "A1.T.UdinaOnFeros",
    ]
    let newMissionIds = [
        "",
        "A1.Convo.Virmire.Avot",
        "A1.Convo.Virmire.Imness",
        "",
        "A1.Convo.Feros.Blakes",
        "A1.Convo.Feros.Newstead",
        "A1.Convo.Citadel.Udina",
    ]

    /// Correct some changes ids
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
        remapMoralityChoices()
        correctMovedMissions()
    }

    private func remapMoralityChoices() {
        for mapData in mapMoralities {
            for var fromMission in Mission.getAllExisting(
                ids: [mapData.fromMissionId],
                gameSequenceUuid: nil
            ) {
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
    }

    private func correctMovedMissions() {
        // load the old missions.
        for index in 0..<oldMissionIds.count {
            guard var fromMission = Mission.getExisting(
                id: oldMissionIds[index],
                gameSequenceUuid: nil
            ) else { continue }
            if let toMission = Mission.get(
                id: newMissionIds[index],
                gameSequenceUuid: fromMission.gameSequenceUuid
            ) {
                _ = toMission.changed(isCompleted: fromMission.isCompleted)
            }
            // delete the old missions.
            _ = fromMission.delete()
        }
        // delete the old data mission.
        _ = DataMission.deleteAll(ids: oldMissionIds)
    }
}
