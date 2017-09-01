//
//  UpdatingTableView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol UpdatingTableView {
	var tableView: UITableView! { get }
	func reloadRows(_ rows: [IndexPath])
	func insertRows(_ rows: [IndexPath])
	func removeRows(_ rows: [IndexPath])
}

extension UpdatingTableView {

	private func allRowsStillExist(_ rows: [IndexPath]) -> Bool {
        var result: Bool = true
        for indexPath in rows {
            if (self.tableView?.numberOfRows(inSection: (indexPath as NSIndexPath).section) ?? 0) < (indexPath as NSIndexPath).row {
                result = false
                break
            }
        }
		return result
	}

	public func reloadRows(_ rows: [IndexPath]) {
        DispatchQueue.main.async {
            if !rows.isEmpty && self.allRowsStillExist(rows) {
				self.tableView?.isUserInteractionEnabled = false
				self.tableView?.beginUpdates()
				self.tableView?.reloadRows(at: rows, with: .automatic)
				self.tableView?.endUpdates()
				self.tableView?.isUserInteractionEnabled = true
			}
		}
	}

	public func insertRows(_ rows: [IndexPath]) {
        DispatchQueue.main.async {
            if !rows.isEmpty && self.allRowsStillExist(rows) {
				self.tableView?.isUserInteractionEnabled = false
				self.tableView?.beginUpdates()
				self.tableView?.insertRows(at: rows, with: .automatic)
				self.tableView?.endUpdates()
				self.tableView?.isUserInteractionEnabled = true
			}
		}
	}

	public func removeRows(_ rows: [IndexPath]) {
        DispatchQueue.main.async {
            if !rows.isEmpty && self.allRowsStillExist(rows) {
				self.tableView?.isUserInteractionEnabled = false
				self.tableView?.beginUpdates()
				self.tableView?.deleteRows(at: rows, with: .automatic)
				self.tableView?.endUpdates()
				self.tableView?.isUserInteractionEnabled = true
			}
		}
	}
}
