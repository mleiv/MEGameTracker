//
//  Shepard.AppearanceAttributeType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	public enum AppearanceAttributeType {
		case
		//FacialStructure
		facialStructure, skinTone, complexion, scar,
		//Head
		neckThickness, faceSize, cheekWidth, cheekBones, cheekGaunt, earsSize, earsOrientation,
		//Eyes
		eyeShape, eyeHeight, eyeWidth, eyeDepth, browDepth, browHeight, irisColor,
		//Jaw
		chinHeight, chinDepth, chinWidth, jawWidth,
		//Mouth
		mouthShape, mouthDepth, mouthWidth, mouthLipSize, mouthHeight,
		//Nose
		noseShape, noseHeight, noseDepth,
		//Hair
		hairColor, hair, brow, browColor, beard, facialHairColor,
		//Makeup
		blushColor, lipColor, eyeShadowColor

		var title: String {
			switch self {
				case .facialStructure : return "Facial Structure"
				case .skinTone : return "Skin Tone"
				case .complexion : return "Complexion"
				case .scar : return "Scar"
				case .neckThickness : return "Neck Thickness"
				case .faceSize : return "Face Size"
				case .cheekWidth : return "Cheek Width"
				case .cheekBones : return "Cheek Bones"
				case .cheekGaunt : return "Cheek Gaunt"
				case .earsSize : return "Ears Size"
				case .earsOrientation : return "Ears Orientation"
				case .eyeShape : return "Eye Shape"
				case .eyeHeight : return "Eye Height"
				case .eyeWidth : return "Eye Width"
				case .eyeDepth : return "Eye Depth"
				case .browDepth : return "Brow Depth"
				case .browHeight : return "Brow Height"
				case .irisColor : return "Iris Color"
				case .chinHeight : return "Chin Height"
				case .chinDepth : return "Chin Depth"
				case .chinWidth : return "Chin Width"
				case .jawWidth : return "Jaw Width"
				case .mouthShape : return "Mouth Shape"
				case .mouthDepth : return "Mouth Depth"
				case .mouthWidth : return "Mouth Width"
				case .mouthLipSize : return "Mouth Lip Size"
				case .mouthHeight : return "Mouth Height"
				case .noseShape : return "Nose Shape"
				case .noseHeight : return "Nose Height"
				case .noseDepth : return "Nose Depth"
				case .hairColor : return "Hair Color"
				case .hair : return "Hair"
				case .brow : return "Brow"
				case .browColor : return "Brow Color"
				case .beard : return "Beard"
				case .facialHairColor : return "Facial Hair Color"
				case .blushColor : return "Blush Color"
				case .lipColor : return "Lip Color"
				case .eyeShadowColor : return "Eye Shadow Color"
			}
		}
	}
}
