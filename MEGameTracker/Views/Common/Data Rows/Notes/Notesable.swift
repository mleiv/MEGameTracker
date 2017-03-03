//
//  Notesable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol Notesable: class {

    var notes: [Note] { get set }
    var originHint: String? { get }
    func getBlankNote() -> Note?
    // handles onChange, select internally
}

