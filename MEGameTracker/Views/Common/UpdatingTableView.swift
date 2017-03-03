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

    fileprivate func allRowsStillExist(_ rows: [IndexPath]) -> Bool {
        for indexPath in rows {
            if (tableView?.numberOfRows(inSection: (indexPath as NSIndexPath).section) ?? 0) < (indexPath as NSIndexPath).row {
                return false
            }
        }
        return true
    }
    
    public func reloadRows(_ rows: [IndexPath]) {
        if !rows.isEmpty && allRowsStillExist(rows) {
            DispatchQueue.main.async {
                self.tableView?.isUserInteractionEnabled = false
                self.tableView?.beginUpdates()
                self.tableView?.reloadRows(at: rows, with: .automatic)
                self.tableView?.endUpdates()
                self.tableView?.isUserInteractionEnabled = true
            }
        }
    }
    
    public func insertRows(_ rows: [IndexPath]) {
        if !rows.isEmpty && allRowsStillExist(rows) {
            DispatchQueue.main.async {
                self.tableView?.isUserInteractionEnabled = false
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: rows, with: .automatic)
                self.tableView?.endUpdates()
                self.tableView?.isUserInteractionEnabled = true
            }
        }
    }
    
    public func removeRows(_ rows: [IndexPath]) {
        if !rows.isEmpty && allRowsStillExist(rows) {
            DispatchQueue.main.async {
                self.tableView?.isUserInteractionEnabled = false
                self.tableView?.beginUpdates()
                self.tableView?.deleteRows(at: rows, with: .automatic)
                self.tableView?.endUpdates()
                self.tableView?.isUserInteractionEnabled = true
            }
        }
    }
}
