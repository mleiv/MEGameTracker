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

	var didStartListeners = true
	var isUpdating = true

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		if !didStartListeners {
			startListeners()
			didStartListeners = true
		}
	}

	// MARK: Protocol - UITableViewDelegate

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
		return UITableView.automaticDimension
	}
	override func tableView(
		_ tableView: UITableView,
		heightForRowAt indexPath: IndexPath
	) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		guard !UIWindow.isInterfaceBuilder else { return }
		if (indexPath as NSIndexPath).row < games.count {
			startSpinner(inView: view.superview)
            var game = games[(indexPath as NSIndexPath).row]
            _ = game.saveAnyChanges(isAllowDelay: false)
			App.current.changeGame { _ in game }
			parent?.dismiss(animated: true, completion: nil)
			stopSpinner(inView: view.superview)
		}
	}

    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
        let restartAction = contextualRestartAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [restartAction])
    }

    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { (action, view, completionHandler) in
                guard !UIWindow.isInterfaceBuilder else { return }

                guard indexPath.row < self.games.count else { return }

                guard self.games.count > 1 else {
                    let alert = UIAlertController(
                        title: nil,
                        message: "App requires at least one game.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(
                        title: "Okay",
                        style: .default,
                        handler: { _ in
                            alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                let game = self.games[indexPath.row]
                let alert = UIAlertController(
                    title: nil,
                    message: "Are you sure you want to delete \(game.shepard?.fullName ?? "this game")",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(
                    title: "Delete",
                    style: .destructive,
                    handler: { _ in
                        let game = self.games.remove(at: indexPath.row)
                        _ = App.current.delete(uuid: game.uuid)
                        completionHandler(true)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic) // temp hack
                }))
                alert.addAction(UIAlertAction(
                    title: "Cancel",
                    style: .cancel,
                    handler: { _ in
                        alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
        })

        action.image = UIImage(named: "Trash")
        action.backgroundColor = MEGameTrackerColor.renegade

        return action
    }

    func contextualRestartAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(
            style: .normal,
            title: "Restart",
            handler: { (action, view, completionHandler) in
                guard !UIWindow.isInterfaceBuilder else { return }

                guard indexPath.row < self.games.count else { return }

                let game = self.games[indexPath.row]
                let alert = UIAlertController(
                    title: nil,
                    message: "Which game are you restarting?",
                    preferredStyle: .actionSheet
                )
                alert.addAction(UIAlertAction(
                    title: "Game 1",
                    style: .default,
                    handler: { _ in
                        let newGame = game.restarted(at: .game1, isAllowDelay: false)
                        App.current.changeGame { _ in newGame }
                        self.parent?.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(
                    title: "Game 2",
                    style: .default,
                    handler: { _ in
                        let newGame = game.restarted(at: .game2, isAllowDelay: false)
                        App.current.changeGame { _ in newGame }
                        self.parent?.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(
                    title: "Game 3",
                    style: .default,
                    handler: { _ in
                        let newGame = game.restarted(at: .game3, isAllowDelay: false)
                        App.current.changeGame { _ in newGame }
                        self.parent?.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                completionHandler(true)
        })

        action.image = UIImage(named: "Plus")
        action.backgroundColor = MEGameTrackerColor.paragon

        return action
    }

	// MARK: Table Elements

	func setupTableCustomCells() {
		let bundle =  Bundle(for: type(of: self))
		tableView.register(UINib(nibName: "GameRow", bundle: bundle), forCellReuseIdentifier: "GameRow")
	}

	// MARK: Setup Page Elements

	func setup(reloadData: Bool = false) {
		isUpdating = true
		tableView.allowsMultipleSelectionDuringEditing = false
		setupTableCustomCells()
		fetchData()
		isUpdating = false
	}

	func reloadDataOnChange(_ x: Bool = false) {
		guard !UIWindow.isInterfaceBuilder else { return }
		guard !isUpdating else { return }
		isUpdating = true
		DispatchQueue.main.async {
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
		games = [GameSequence.getDummy(), GameSequence.getDummy()].compactMap { $0 }
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
		_ = App.onCurrentShepardChange.subscribe(with: self, callback: reloadDataOnChange)
	}
}
