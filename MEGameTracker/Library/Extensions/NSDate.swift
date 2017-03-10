//
//  NSDate.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/12/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Date {

	fileprivate static var sharedFormatter: DateFormatter = {
		var formatter = DateFormatter()
		return formatter
	}()

	fileprivate func formatStandardStyle(
		_ dateStyle: DateFormatter.Style = .long,
		_ timeStyle: DateFormatter.Style = .long
	) -> String? {
		Date.sharedFormatter.dateStyle = dateStyle
		Date.sharedFormatter.timeStyle = timeStyle
		return Date.sharedFormatter.string(from: self)
	}

	fileprivate func formatCustomString(_ format: String = "MMMMd") -> String? {
		Date.sharedFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: nil)
		let dateString = Date.sharedFormatter.string(from: self)
		Date.sharedFormatter.dateFormat = nil //cleanup
		return dateString
	}

	public func format(_ format: DateFormat) -> String? {
		switch format {
		case .typical: return self.formatStandardStyle(.short, .short)
		}
	}
}
public enum DateFormat {
	case typical
}
