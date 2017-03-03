//
//  TextDataRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol TextDataRowType {
    var view: TextDataRow? { get set }
    var text: String? { get }
    var linkOriginController: UIViewController? { get }
    var isHideOnEmpty: Bool { get }
    var showRowDivider: Bool? { get }
    var borderTop: Bool? { get }
    var borderBottom: Bool? { get }
    mutating func setup(dataRow: TextDataRow)
    
    mutating func setupView()
    func hideEmptyView()
}

extension TextDataRowType {
    public var text: String? { return nil }
    public var linkOriginController: UIViewController? { return nil }
    public var isHideOnEmpty: Bool { return true }
    public var showRowDivider: Bool? { return nil }
    public var borderTop: Bool? { return nil }
    public var borderBottom: Bool? { return nil }
    public mutating func setup(dataRow: TextDataRow) {}
    
    public mutating func setupView() {
        guard let view = self.view, !view.isSettingUp else { return }
        view.isSettingUp = true
        if view.nib == nil { view.setup() }
        
        view.nib?.rowDivider?.isHidden = !(showRowDivider ?? view.showRowDivider)
        view.nib?.top = borderTop ?? view.borderTop
        view.nib?.bottom = borderBottom ?? view.borderBottom
        view.nib?.textView?.text = text
        view.nib?.textView?.linkOriginController = linkOriginController
        setup(dataRow: view)
        
        view.setupTableHeader()
        hideEmptyView()
        
        view.nib?.textView?.layoutSubviews()
        view.isSettingUp = false
    }
    
    public func hideEmptyView() {
        view?.isHidden = isHideOnEmpty && !UIWindow.isInterfaceBuilder && (text ?? "").isEmpty
    }
}


