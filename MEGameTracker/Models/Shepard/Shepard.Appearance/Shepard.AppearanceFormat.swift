//
//  Shepard.AppearanceFormat.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {
    
    /// A library of formatting functions for Appearance
    public struct AppearanceFormat {
    
// MARK: Constants

        public static let ExpectedCodeLength: [Gender: [GameVersion: Int]] = [
            .male: [.game1: 35, .game2: 34, .game3: 34],
            .female: [.game1: 37, .game2: 36, .game3: 36]
        ]
        
        public static let CodeLengthIncorrect = "Warning: code length (%d) does not match game selected (expected %d)"
    
        /// The alphabetic characters used in ME's hex-like int-to-char mapping.
        public static let AvailableAlphabet = "123456789ABCDEFGHIJKLMNPQRSTUVW"
        
// MARK: Basic Actions

        /// Returns a human-readable error message if the appearance code doesn't parse properly.
        public static func codeLengthError(_ code: String, gender: Gender, game: GameVersion) -> String? {
            let reportLength = ExpectedCodeLength[gender]?[game] ?? 0
            if reportLength == code.characters.count {
                return nil
            } else {
                return String(format: CodeLengthIncorrect, code.characters.count, reportLength)
            }
        }
        
        /// Returns alphabetic character for the attribute int value.
        public static func formatAttribute(_ attributeValue: Int?) -> String {
            if attributeValue > 0 {
                return AvailableAlphabet[attributeValue! - 1] // starts at 1, not 0
            }
            return "X"
        }
        
        /// Returns int value for the attribute alphabetic character.
        public static func unformatAttribute(_ attributeString: Character?) -> Int {
            return (AvailableAlphabet.intIndexOf(attributeString ?? "X") ?? -1) + 1
        }
        
        /// Unformats a string from XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X into allowed characters
        public static func unformatCode(_ code: String) -> String {
            return code.uppercased().onlyCharacters(AvailableAlphabet + "X")
        }
        
        /// Formats an alphanumeric string into the XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X format
        public static func formatCode(_ code: String!, lastCode: String! = nil) -> String {
            //strip to valid characters
            var unformattedCode: String! = unformatCode(code)
            if unformattedCode.isEmpty {
                return ""
            }
            if lastCode != nil {
                //if characters removed by user, change to remove valid characters instead of other formatting
                let lastUnformattedCode = unformatCode(lastCode)
                let requestedSubtractChars = lastCode.length - code.length
                let actualSubtractChars = max(0, lastUnformattedCode.length - unformattedCode.length)
                if requestedSubtractChars > 0 && actualSubtractChars < requestedSubtractChars {
                    let subtractChars = requestedSubtractChars - actualSubtractChars
                    unformattedCode = subtractChars >= unformattedCode.length  ? "" : unformattedCode.stringFrom(0, to: -1 * subtractChars)
                }
            }
            //add formatting
            var formattedCode = unformattedCode.replacingOccurrences(of: "([^\\.]{3})", with: "$1.", options: NSString.CompareOptions.regularExpression, range: nil)
            if formattedCode.stringFrom(-1) == "." {
                formattedCode = formattedCode.stringFrom(0, to: -1)
            }
            return formattedCode
        }
        
        public static func isEmpty(_ code: String) -> Bool {
            return code.uppercased().onlyCharacters(AvailableAlphabet).isEmpty
        }
    }
}
