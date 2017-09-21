//
//  CoreDataMigrations.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/10/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct CoreDataMigrations {

	// post-load migrations

	public static var isRunning = false
	public static var onStart = Signal<Bool>()
	public static var onPercentProgress = Signal<Int>()
	public static var onFinish = Signal<Bool>()
}
