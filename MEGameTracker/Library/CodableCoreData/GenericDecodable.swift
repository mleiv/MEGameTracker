//
//  GenericDecodable.swift
//
//  Copyright 2017 Emily Ivie

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.
//

import Foundation

/// Required to do a chained generic init() beginning with JSONDecoder.decode(...)
///
/// See: CodableCoreDataStorable::init?(coreItem: EntityType)
struct GenericDecodable: Decodable {
    let decoder: Decoder
    public init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

