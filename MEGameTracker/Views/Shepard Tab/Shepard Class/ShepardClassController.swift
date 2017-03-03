//
//  ShepardClassController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class ShepardClassController: UIViewController, SideEffectsable {

    @IBOutlet weak var soldierRadio: RadioOptionRowView?
    @IBOutlet weak var soldierSideEffectsView: SideEffectsView?
    @IBOutlet weak var engineerRadio: RadioOptionRowView?
    @IBOutlet weak var engineerSideEffectsView: SideEffectsView?
    @IBOutlet weak var adeptRadio: RadioOptionRowView?
    @IBOutlet weak var adeptSideEffectsView: SideEffectsView?
    @IBOutlet weak var infiltratorRadio: RadioOptionRowView?
    @IBOutlet weak var infiltratorSideEffectsView: SideEffectsView?
    @IBOutlet weak var sentinelRadio: RadioOptionRowView?
    @IBOutlet weak var sentinelSideEffectsView: SideEffectsView?
    @IBOutlet weak var vanguardRadio: RadioOptionRowView?
    @IBOutlet weak var vanguardSideEffectsView: SideEffectsView?
    
    public var sideEffects: [String]?
    fileprivate var shepard: Shepard?

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard !UIWindow.isInterfaceBuilder else { return }
        setup()
        startListeners()
    }
    
    func setup() {
        fetchData()
        
        if !UIWindow.isInterfaceBuilder {
            soldierSideEffectsView?.controller = self
            engineerSideEffectsView?.controller = self
            adeptSideEffectsView?.controller = self
            infiltratorSideEffectsView?.controller = self
            sentinelSideEffectsView?.controller = self
            vanguardSideEffectsView?.controller = self
            
            soldierRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .soldier)
                self?.setupRadios()
            }
            engineerRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .engineer)
                self?.setupRadios()
            }
            adeptRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .adept)
                self?.setupRadios()
            }
            infiltratorRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .infiltrator)
                self?.setupRadios()
            }
            sentinelRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .sentinel)
                self?.setupRadios()
            }
            vanguardRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(class: .vanguard)
                self?.setupRadios()
            }
        }
        
        setupRadios()
    }

    func fetchData() {
        guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
        shepard = App.current.game?.shepard
    }
    
    func fetchDummyData() {
        shepard = Shepard.getDummy()
    }
    
    func setupRadios() {
        soldierRadio?.isOn = shepard?.classTalent == .soldier
        engineerRadio?.isOn = shepard?.classTalent == .engineer
        adeptRadio?.isOn = shepard?.classTalent == .adept
        infiltratorRadio?.isOn = shepard?.classTalent == .infiltrator
        sentinelRadio?.isOn = shepard?.classTalent == .sentinel
        vanguardRadio?.isOn = shepard?.classTalent == .vanguard
    }
    
    func reloadDataOnChange() {
        DispatchQueue.main.async {
            self.fetchData()
            self.setupRadios()
        }
    }
    
    func reloadOnShepardChange() {
        if shepard?.uuid != App.current.game?.shepard?.uuid {
            shepard = App.current.game?.shepard
            reloadDataOnChange()
        }
    }
    
    func startListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
        // listen for gameVersion changes only
        App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadOnShepardChange)
    }
}
