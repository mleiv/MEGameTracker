//
//  Change20171022.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/5/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

public struct Change20180203: CoreDataMigrationType {
    typealias MoralityIdMap = (fromId: String, toId: String)
    typealias MoralityMissionMap = (fromMissionId: String, toMissionId: String, ids: [MoralityIdMap])

    let mapMoralities: [MoralityMissionMap] = [(
        fromMissionId: "A2.Convo.Jack",
        toMissionId: "A2.Convo.Jack",
        ids: [
            (fromId: "A2.Convo.Jack.R14", toId: "A2.Convo.Jack.R12B"),
        ]
    ), (
        fromMissionId: "M2.Horizon",
        toMissionId: "A2.Convo.Kelly",
        ids: [
            (fromId: "M2.Horizon.P18", toId: "A2.Convo.Kelly.P4"),
            (fromId: "M2.Horizon.R18", toId: "A2.Convo.Kelly.R4A"),
            (fromId: "M2.Horizon.R19", toId: "A2.Convo.Kelly.R4B"),
            ]
    ), (
        fromMissionId: "M2.CollectorShip",
        toMissionId: "A2.Convo.Kelly",
        ids: [
            (fromId: "M2.CollectorShip.P12", toId: "A2.Convo.Kelly.P4D"),
            (fromId: "M2.CollectorShip.R12", toId: "A2.Convo.Kelly.R4D"),
        ]
    ), (
        fromMissionId: "A2.Convo.Thane",
        toMissionId: "A2.Convo.Thane",
        ids: [
            (fromId: "A2.Convo.Thane.R41", toId: "A2.Convo.Thane.R39"),
        ]
    )]

    /// Correct some changes ids
    public func run() {
        // only run if prior bad data may have been saved
        guard App.current.lastBuild > 0 else { return }
//        setMissionCompletedDates()
//        setItemAcquiredDates()
//        setDecisionSelectedDates()
//        setEventTriggeredDates()
        remapMoralityChoices()
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

    private func cleanup() {}

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

//    private func setMissionCompletedDates() {
//        let manager = CoreDataManager.current
//        let missions = Mission.getAllFromData(with: manager) { fetchRequest in
//            fetchRequest.predicate = NSPredicate(
//                format: "(%K == true) AND (%K == nil)",
//                #keyPath(GameMissions.isCompleted),
//                #keyPath(GameMissions.completedDate)
//            )
//        }
//        for var mission in missions {
//            mission.completedDate = mission.modifiedDate
//            _ = mission.save()
//        }
//    }
//
//    private func setItemAcquiredDates() {
//        let manager = CoreDataManager.current
//        let items = Item.getAllFromData(with: manager) { fetchRequest in
//            fetchRequest.predicate = NSPredicate(
//                format: "(%K == true) AND (%K == nil)",
//                #keyPath(GameItems.isAcquired),
//                #keyPath(GameItems.acquiredDate)
//            )
//        }
//        for var item in items {
//            item.acquiredDate = item.modifiedDate
//            _ = item.save()
//        }
//    }
//
//    private func setDecisionSelectedDates() {
//        let manager = CoreDataManager.current
//        let decisions = Decision.getAllFromData(with: manager) { fetchRequest in
//            fetchRequest.predicate = NSPredicate(
//                format: "(%K == true) AND (%K == nil)",
//                #keyPath(GameDecisions.isSelected),
//                #keyPath(GameDecisions.selectedDate)
//            )
//        }
//        for var decision in decisions {
//            decision.selectedDate = decision.modifiedDate
//            _ = decision.save()
//        }
//    }
//
//    private func setEventTriggeredDates() {
//        let manager = CoreDataManager.current
//        let events = Event.getAllFromData(with: manager) { fetchRequest in
//            fetchRequest.predicate = NSPredicate(
//                format: "(%K == true) AND (%K == nil)",
//                #keyPath(GameEvents.isTriggered),
//                #keyPath(GameEvents.triggeredDate)
//            )
//        }
//        for var event in events {
//            event.triggeredDate = event.modifiedDate
//            _ = event.save()
//        }
//    }
}
