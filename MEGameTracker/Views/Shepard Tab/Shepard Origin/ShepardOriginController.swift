//
//  ShepardOriginController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/29/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class ShepardOriginController: UIViewController, SideEffectsable {
    
    @IBOutlet weak var earthbornRadio: RadioOptionRowView?
    @IBOutlet weak var earthbornSideEffectsView: SideEffectsView?
    @IBOutlet weak var spacerRadio: RadioOptionRowView?
    @IBOutlet weak var spacerSideEffectsView: SideEffectsView?
    @IBOutlet weak var colonistRadio: RadioOptionRowView?
    @IBOutlet weak var colonistSideEffectsView: SideEffectsView?
    
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
            earthbornSideEffectsView?.controller = self
            spacerSideEffectsView?.controller = self
            colonistSideEffectsView?.controller = self
        
            earthbornRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(origin: .earthborn)
                DispatchQueue.main.async {
                self?.setupRadios()
                }
            }
            spacerRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(origin: .spacer)
                self?.setupRadios()
            }
            colonistRadio?.onChange = { [weak self] _ in
                self?.shepard?.change(origin: .colonist)
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
        earthbornRadio?.isOn = shepard?.origin == .earthborn
        spacerRadio?.isOn = shepard?.origin == .spacer
        colonistRadio?.isOn = shepard?.origin == .colonist
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
