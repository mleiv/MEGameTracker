//
//  SettingsController.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/12/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController, Spinnerable {

    var games: [GameSequence] = []
    
    var didstartListeners = true
    var isUpdating = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if !didstartListeners {
            startListeners()
            didstartListeners = true
        }
    }

    //MARK: Protocol - UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return games.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameRow") as? GameRow {
            setupGameRow((indexPath as NSIndexPath).row, cell: cell)
            return cell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard !UIWindow.isInterfaceBuilder else { return }
        if (indexPath as NSIndexPath).row < games.count {
            startSpinner(inView: view.superview)
            let game = games[(indexPath as NSIndexPath).row]
            App.current.change(game: game)
            parent?.dismiss(animated: true, completion: nil)
            stopSpinner(inView: view.superview)
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath
    ) -> Bool {
        guard !UIWindow.isInterfaceBuilder else { return false }
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard !UIWindow.isInterfaceBuilder else { return }
        if editingStyle == .delete {
            if games.count == 1 {
                let alert = UIAlertController(title: nil, message: "App requires at least one game.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {
                    (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
                tableView.reloadData() // TODO: better way to cancel delete?
            } else if (indexPath as NSIndexPath).row < games.count {
                startSpinner(inView: view.superview)
                isUpdating = true
                let game = games.remove(at: (indexPath as NSIndexPath).row)
                _ = App.current.delete(uuid: game.uuid)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                tableView.endUpdates()
                isUpdating = false
                stopSpinner(inView: view.superview)
            }
        }
    }
    
    
    //MARK: Table Elements
    
    func setupTableCustomCells() {
        let bundle =  Bundle(for: type(of: self))
        tableView.register(UINib(nibName: "GameRow", bundle: bundle), forCellReuseIdentifier: "GameRow")
    }
    
    
    //MARK: Setup Page Elements

    func setup(reloadData: Bool = false) {
        isUpdating = true
        tableView.allowsMultipleSelectionDuringEditing = false
        setupTableCustomCells()
        fetchData()
        isUpdating = false
    }
    
    func reloadDataOnChange() {
        guard !UIWindow.isInterfaceBuilder else { return }
        guard !isUpdating else { return }
        isUpdating = true
        DispatchQueue.main.async{
            self.fetchData()
            self.tableView.reloadData()
            self.isUpdating = false
        }
    }

    func fetchData() {
        guard !UIWindow.isInterfaceBuilder else { return fetchDummyData() }
        games = App.current.getAllGames().sorted(by: GameSequence.sort)
    }
    
    func fetchDummyData() {
        games = [GameSequence.getDummy(), GameSequence.getDummy()].flatMap { $0 }
    }
    
    func setupGameRow(_ row: Int, cell: GameRow) {
        if row < games.count {
            cell.define(shepard: games[row].shepard)
        }
    }

    func startListeners() {
        guard !UIWindow.isInterfaceBuilder else { return }
        //listen for relationship changes
        App.onCurrentShepardChange.cancelSubscription(for: self)
        _ = App.onCurrentShepardChange.subscribe(on: self, callback: reloadDataOnChange)
    }
}
