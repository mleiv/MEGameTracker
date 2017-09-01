//
//  GameSegments.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

@IBDesignable
final public class GameSegments: UIView {

	public var games: [GameVersion] = [ .game1 ] {
		didSet {
			setup()
		}
	}

	private var nib: GameSegmentsNib?

	private var didSetup = false

	public override func layoutSubviews() {
//		if !didSetup {
//			setup()
//		}
		super.layoutSubviews()
	}

	private func setup() {
		guard let nib = getNib() else { return }
		nib.game1?.text = games.contains(.game1) ? "Game 1" : "X"
		nib.game2?.text = games.contains(.game2) ? "Game 2" : "X"
		nib.game3?.text = games.contains(.game3) ? "Game 3" : "X"
		didSetup = true
	}

	private func getNib() -> GameSegmentsNib? {
		if self.nib == nil, let nib = GameSegmentsNib.loadNib() {
			insertSubview(nib, at: 0)
			nib.fillView(self)
			self.nib = nib
		}
		return nib
	}
}
