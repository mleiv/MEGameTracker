//
//  Shepard.AppearanceGroupType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	public enum AppearanceGroupType {

		case facialStructure, head, eyes, jaw, mouth, nose, hair, makeup

		var title: String {
			switch self {
			case .facialStructure: return "Facial Structure"
			case .head: return "Head"
			case .eyes: return "Eyes"
			case .jaw: return "Jaw"
			case .mouth: return "Mouth"
			case .nose: return "Nose"
			case .hair: return "Hair"
			case .makeup: return "Makeup"
			}
		}
	}
}
