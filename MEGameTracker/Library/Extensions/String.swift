//
//  String.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/25/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

extension String {
	func intIndexOf(_ character: Character) -> Int? {
		guard let index = index(of: character) else { return nil }
		return distance(from: startIndex, to: index)
	}
	/**
		Pads the left side of a string with the specified string up to the specified length.
		Does not clip the string if too long.

		- parameter padding:   The string to use to create the padding (if needed)
		- parameter length:	Integer target length for entire string
		- returns: The padded string
	*/
	func lpad(_ padding: String, length: Int) -> (String) {
		if self.count > length {
			return self
		}
		return "".padding(toLength: length - self.count, withPad:padding, startingAt:0) + self
	}
	/**
		Pads the right side of a string with the specified string up to the specified length.
		Does not clip the string if too long.

		- parameter padding:   The string to use to create the padding (if needed)
		- parameter length:	Integer target length for entire string
		- returns: The padded string
	*/
	func rpad(_ padding: String, length: Int) -> (String) {
		if self.count > length { return self }
		return self.padding(toLength: length, withPad:padding, startingAt:0)
	}
	/**
		Returns string with left and right spaces trimmed off.

		- returns: Trimmed String
	*/
	func trim() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespaces)
	}
	/**
		Shortcut for getting length (since Swift keeps cahnging this).

		- returns: Int length of string
	*/
	var length: Int {
		return self.count
	}
	/**
		Returns character at a specific position from a string.

		- parameter index:			   The position of the character
		- returns: Character
	*/
	subscript (index: Int) -> Character {
		return self[self.index(self.startIndex, offsetBy: index)]
	}
	subscript (index: Int) -> String {
		return String(self[index] as Character)
	}
	/**
		Returns substring extracted from a string at start and end location.

		- parameter start:			   Where to start (-1 acceptable)
		- parameter end:				 (Optional) Where to end (-1 acceptable) - default to end of string
		- returns: String
	*/
	func stringFrom(_ start: Int, to end: Int? = nil) -> String {
		var maximum = self.count

		let i = start < 0 ? self.endIndex : self.startIndex
		let ioffset = min(maximum, max(-1 * maximum, start))
		let startIndex = self.index(i, offsetBy: ioffset)

		maximum -= start

		let j = end < 0 ? self.endIndex : self.startIndex
		let joffset = min(maximum, max(-1 * maximum, end ?? 0))
		let endIndex = end != nil && end! < self.count ? self.index(j, offsetBy: joffset) : self.endIndex
		return String(self[startIndex..<endIndex])
	}
	/**
		Returns substring composed of only the allowed characters.

		- parameter allowed:			 String list of acceptable characters
		- returns: String
	*/
	func onlyCharacters(_ allowed: String) -> String {
		let search = allowed
		return filter({ search.contains($0) }).reduce("", { $0 + String($1) })
	}
	/**
		Simple pattern matcher. Requires full match (ie, includes ^$ implicitly).

		- parameter pattern:			 Regex pattern (includes ^$ implicitly)
		- returns: true if full match found
	*/
	func matches(_ pattern: String) -> Bool {
		let test = NSPredicate(format:"SELF MATCHES %@", pattern)
		return test.evaluate(with: self)
	}
	/**
		Replaces a string with another string

		:param: find				The string to search for
		:param: replace			 The string to replace with
		:returns: new string
	*/
	func replace(_ find: String, _ replace: String) -> String {
		var string = self
		if let range = string.range(of: find) {
			string.replaceSubrange(range, with: replace)
		}
		return string
	}
}

extension String {
	//http://stackoverflow.com/questions/27914053/localizewithformat-and-variadic-arguments-in-swift
	func localize(_ args: CVarArg...) -> String {
		return String(format: NSLocalizedString("\(self)", comment: ""), locale: Locale.current, arguments: args)
	}
}
