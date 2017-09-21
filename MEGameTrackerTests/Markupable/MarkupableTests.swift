//
//  MarkupableTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 4/4/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

class MarkupableTests: XCTestCase {

    override func setUp() {
        super.setUp()
		Styles.current.initialize(fromWindow: nil)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLabel() {
		let label = MarkupLabel()
		label.identifier = "Body.AccentColor"
		label.text = "**Bold**"
		let attributes: [NSAttributedStringKey: Any] = label.attributedText?.attributes(
			at: 0,
			longestEffectiveRange: nil,
			in: NSRange(location: 0, length: label.attributedText?.length ?? 0)
		) ?? [:]
//		"identifier": Body.NormalColor
        let color = attributes[NSAttributedStringKey.foregroundColor] as? UIColor
		XCTAssert(color == Styles.Colors.accentColor, "Color is incorrect")
        let font = attributes[NSAttributedStringKey.font] as? UIFont
		XCTAssert(font == Styles.Fonts.body.boldStyle.getUIFont(), "Font is incorrect")
    }

}
