//
//  LoadStatus.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/30/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// Make your components enum adhere to this protocol
protocol LoadStatusComponent: Hashable {
	static func list() -> [Self]
}

/// Example:
///
///	 enum MyEnum: LoadStatusComponent {
///		 case test
///		 func list() -> [MyEnum] { return [test] }
///	 }
///	 var status = LoadStatus<MyEnum>()
///	 func reloadPage() {
///		 status.reset()
///		 ... start spinner, load stuff async
///		 status.markIsDone(.test)
///		 if status.isComplete == true { ... stop spinner }
///	 }
struct LoadStatus<Component: LoadStatusComponent> {
	private var components: [Component: Bool] = [:]
	var isComplete: Bool {
		return components.reduce(true) { $0 && $1.1 }
	}
	init() {
		reset()
	}
	mutating func markIsDone(_ component: Component) {
		components[component] = true
	}
	mutating func reset() {
		components = [:]
		for key in Component.list() {
			components[key] = false
		}
	}
}
