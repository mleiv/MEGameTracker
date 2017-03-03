//
//  VoiceActorLinkable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/23/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol VoiceActorLinkable: class {

    var voiceActorName: String? { get set }
    // handles onChange, select internally
}

