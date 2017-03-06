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
    typealias MoralityMissionMap = (fromMission: String, toMission: String, ids: [MoralityIdMap])
    let mapMoralities: [MoralityMissionMap] = [(
        fromMission: "A2.L.Miranda",
        toMission: "A2.Convo.Miranda",
        ids: [
            (fromId: "A2.L.Miranda.P1", toId: "A2.Convo.Miranda.P30"),
            (fromId: "A2.L.Miranda.P14", toId: "A2.Convo.Miranda.P40"),
            (fromId: "A2.L.Miranda.P15", toId: "A2.Convo.Miranda.P41"),
        ]
    ),(
        fromMission: "A2.L.Mordin",
        toMission: "A2.Convo.Mordin",
        ids: [
            (fromId: "A2.L.Mordin.P1", toId: "A2.Convo.Mordin.P30"),
            (fromId: "A2.L.Mordin.R1", toId: "A2.Convo.Mordin.R30"),
        ]
    ),(
        fromMission: "A2.L.Jacob",
        toMission: "A2.Convo.Jacob",
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
        
    )]
    /// Correct some changes ids
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
        
        for mapData in mapMoralities {
            if var fromMission = Mission.getExisting(id: mapData.fromMission, gameSequenceUuid: nil),
                var toMission = Mission.get(id: mapData.toMission) {
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
