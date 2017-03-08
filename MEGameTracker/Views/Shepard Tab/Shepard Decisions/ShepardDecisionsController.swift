//
//  ShepardDecisionsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/19/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ShepardDecisionsController: UIViewController, Spinnerable {

    @IBOutlet weak var gameSegment: IBStyledSegmentedControl!
    
    // Decisionsable
    @IBOutlet public weak var decisionsView: DecisionsView?
    
    @IBAction func gameChanged(_ sender: UISegmentedControl) {
        changeGame(index: gameSegment.selectedSegmentIndex)
    }
    
    // Decisionsable
    public var decisions: [Decision] = []
    
    public var originHint: String? { return shepard?.fullName }
    fileprivate var shepard: Shepard?
    
    var gameVersion = GameVersion.game1
    var allDecisions: [GameVersion: [Decision]] = [:]
    var isUpdating = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        guard !UIWindow.isInterfaceBuilder else { return }
        setup()
        startListeners()
    }
    
    func setup() {
        isUpdating = true
        
        fetchData()
    
        if !UIWindow.isInterfaceBuilder {
            // preload other game version decisions async
            DispatchQueue.global(qos: .background).async { [weak self] () in
                let reloadData = self?.decisions.isEmpty ?? false
                if self?.gameVersion != .game1 {
                    self?.allDecisions[.game1] = Decision.getAll(gameVersion: .game1).sorted(by: Decision.sort)
                }
                if self?.gameVersion != .game2 {
                    self?.allDecisions[.game2] = Decision.getAll(gameVersion: .game2).sorted(by: Decision.sort)
                }
                if self?.gameVersion != .game3 {
                    self?.allDecisions[.game3] = Decision.getAll(gameVersion: .game3).sorted(by: Decision.sort)
                }
                if reloadData {
                    DispatchQueue.main.async {
                        self?.setupDecisions(isReloadData: true)
                    }
                }
            }
        }
        
        setupDecisions()
        gameSegment.selectedSegmentIndex = gameVersion.index
        isUpdating = false
    }

    func fetchData() {
        guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
        shepard = App.current.game?.shepard
        // set game version
        gameVersion = shepard?.gameVersion ?? gameVersion
        // load decisions
        allDecisions[gameVersion] = Decision.getAll(gameVersion: gameVersion).sorted(by: Decision.sort)
    }
    
    func fetchDummyData() {
        shepard = Shepard.getDummy()
        let game = shepard?.gameVersion ?? .game1
        allDecisions[game] = [Decision.getDummy(), Decision.getDummy()].flatMap { $0 }
    }
    
    func changeGame(index: Int) {
        startSpinner(inView: view)
        gameVersion = {
            switch index {
            case 0: return .game1
            case 1: return .game2
            case 2: return .game3
            default: return .game1
            }
        }()
        setupDecisions(isReloadData: true)
        stopSpinner(inView: view)
    }
    
    func reloadDataOnChange() {
        guard !isUpdating else { return }
        isUpdating = true
        DispatchQueue.main.async{
            self.setup()
            self.isUpdating = false
        }
    }
    
    func startListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
        // listen for gameVersion changes
        App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadDataOnChange)
        // listen for decision changes
        let gameVersion = self.gameVersion
        Decision.onChange.cancelSubscription(for: self)
        _ = Decision.onChange.subscribe(on: self) { [weak self] changed in
            if let object = changed.object,
                let index = self?.allDecisions[gameVersion]?.index(of: object) {
                self?.allDecisions[gameVersion]?[index] = object
                DispatchQueue.main.async {
                    self?.setupDecisions()
                }
            }
        }
    }
}

extension ShepardDecisionsController: Decisionsable {
    //public var decisionsView: DecisionsView? // already declared
    //public var originHint: String? // already declared
    //public var decisions: [Decision] // already declared
    
    func setupDecisions(isReloadData: Bool = false) {
        decisions = allDecisions[gameVersion] ?? []
        decisionsView?.isShowGameVersion = false
        decisionsView?.controller = self
        decisionsView?.setup()
    }
}
