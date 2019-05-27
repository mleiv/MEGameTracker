//
//  Notes.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/19/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class NotesView: SimpleArrayDataRow {

	private lazy var dummyNotes: [Note] = {
		if let note = Note.getDummyNote() {
			return [note]
		}
		return []
	}()
	public var notes: [Note] {
		return UIWindow.isInterfaceBuilder ? dummyNotes : (controller?.notes ?? [])
	}
	public var controller: Notesable?{
        didSet {
            reloadData()
        }
    }
	var isBorderBottom: Bool?
	var notesNib: NotesNib?

	override var heading: String? { return "Notes" }
	override var cellNibs: [String] { return ["NoteRow"] }
	override var rowCount: Int { return notes.count }
	override var originHint: String? { return controller?.originHint }
	override var viewController: UIViewController? { return controller as? UIViewController }

	override func setupRow(cell: UITableViewCell, indexPath: IndexPath) {
		guard notes.indices.contains((indexPath as NSIndexPath).row) else { return }
		(cell as? NoteRow)?.define(note: notes[(indexPath as NSIndexPath).row])
	}

	override func identifierForIndexPath(_ indexPath: IndexPath) -> String {
		return cellNibs[0]
	}

	override func openRow(indexPath: IndexPath, sender: UIView?) {
		guard notes.indices.contains((indexPath as NSIndexPath).row) else { return }
		let note = notes[(indexPath as NSIndexPath).row]
		openNote(note, sender: sender)
	}

	func openNote(_ note: Note?, sender: UIView?) {
		startParentSpinner()
		DispatchQueue.global(qos: .background).async {
			guard let note: Note = {
				if note == nil, let blankNote = self.controller?.getBlankNote() {
					let note = Note(identifyingObject: blankNote.identifyingObject)
					return note
				} else if let note = note {
					return note
				}
				return nil
			}() else {
				self.stopParentSpinner()
				return
			}
			// load editor
			let bundle = Bundle(for: type(of: self))
			if let editorNavigationController = UIStoryboard(name: "NotesEditor", bundle: bundle)
					.instantiateInitialViewController() as? UINavigationController,
				let editor = editorNavigationController.visibleViewController as? NotesEditorController {
				editor.note = note
				editor.originHint = self.controller?.originHint
				editor.originPrefix = "Re"
				editorNavigationController.modalPresentationStyle = .popover
				if let popover = editorNavigationController.popoverPresentationController {
					editor.preferredContentSize = CGSize(width: 400, height: 400)
					editor.popover = popover
					popover.sourceView = sender
					popover.sourceRect = sender?.bounds ?? CGRect.zero
				}
				DispatchQueue.main.async {
					self.viewController?.present(editorNavigationController, animated: true, completion: nil)
					self.stopParentSpinner()
				}
				return
			}
			self.stopParentSpinner()
		}
	}

	func deleteRow(_ note: Note, sender: UIView?) -> Bool {
		var note = note
		if note.delete(), let index = notes.firstIndex(of: note) {
			controller?.notes.remove(at: index)
			let rows: [IndexPath] = [IndexPath(row: index, section: 0)]
			removeRows(rows)
			return true
		} else {
			print("Could not delete note") // TODO: alert
			return false
		}
	}

	override func startListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Note.onChange.cancelSubscription(for: self)
		_ = Note.onChange.subscribe(with: self) { [weak self] changed in
			if let uuid = UUID(uuidString: changed.id),
                let index = self?.notes.firstIndex(where: { $0.uuid == uuid }) ,
				   let newRow = changed.object ?? Note.get(uuid: uuid) {
				self?.controller?.notes[index] = newRow
				let rows: [IndexPath] = [IndexPath(row: index, section: 0)]
				self?.reloadRows(rows)
				// make sure controller listens didset here and updates its own object's notes list
			} else if let note = changed.object,
				let blankNote = self?.controller?.getBlankNote(),
				note.identifyingObject == blankNote.identifyingObject {
				self?.controller?.notes.append(note)
				if let index = self?.notes.firstIndex(of: note) {
					let rows: [IndexPath] = [IndexPath(row: index, section: 0)]
					self?.insertRows(rows)
				}
			}
		}
	}

	override func removeListeners() {
		guard !UIWindow.isInterfaceBuilder else { return }
		Note.onChange.cancelSubscription(for: self)
	}

	override func setup() {
		isSettingUp = true
		if notesNib == nil, let view = NotesNib.loadNib(heading: heading, cellNibs: cellNibs) {
			insertSubview(view, at: 0)
			view.fillView(self)
			notesNib = view
			notesNib?.onAdd = { [weak self] in
				self?.openNote(nil, sender: self?.notesNib?.addButton)
			}
			nib = notesNib
		}
		super.setup()
	}

	override func hideEmptyView() {
		if isBorderBottom == nil {
            isBorderBottom = borderBottom
		}
		borderBottom = isBorderBottom == true && !notes.isEmpty
	}
}

extension NotesView { // :UITableViewDelegate

	@objc public func tableView(
		_ tableView: UITableView,
		commitEditingStyle editingStyle: UITableViewCell.EditingStyle,
		forRowAtIndexPath indexPath: IndexPath
	) {
		if notes.indices.contains((indexPath as NSIndexPath).row) && editingStyle == .delete {
			tableView.isUserInteractionEnabled = false
			let cell = tableView.cellForRow(at: indexPath)
			_ = deleteRow(notes[(indexPath as NSIndexPath).row], sender: cell)
			tableView.isUserInteractionEnabled = true
		}
	}
}
