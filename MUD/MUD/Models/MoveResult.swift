//
//  MoveResult.swift
//  MUD
//
//  Created by Jordan Christensen on 3/5/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import Foundation


struct MoveResult: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case title
        case desc = "description"
        case players
        case errorMessage = "error_msg"
    }
    
    var name: String?
    var title: String?
    var desc: String?
    var players: [String]?
    var errorMessage: String?
}


struct LocationResult: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case title
        case desc = "description"
        case players
        case uuid
    }
    
    var uuid: UUID?
    var name: String?
    var title: String?
    var desc: String?
    var players: [String]?
}
