//
//  Room.swift
//  MUD
//
//  Created by Jordan Christensen on 3/5/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import Foundation

class Room: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc = "description"
        case north = "n_to"
        case south = "s_to"
        case east = "e_to"
        case west = "w_to"
    }
    
    init(id: Int, title: String, desc: String, north: Int, south: Int, east: Int, west: Int) {
        self.id = id
        self.title = title
        self.desc = desc
        self.north = north
        self.south = south
        self.east = east
        self.west = west
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(Int.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let desc = try container.decode(String.self, forKey: .desc)
        let north = try container.decode(Int.self, forKey: .north)
        let south = try container.decode(Int.self, forKey: .south)
        let east = try container.decode(Int.self, forKey: .east)
        let west = try container.decode(Int.self, forKey: .west)
        
        self.id = id
        self.title = title
        self.desc = desc
        self.north = north
        self.south = south
        self.east = east
        self.west = west
    }
    
    var id: Int
    var title: String
    var desc: String
    var north: Int
    var south: Int
    var east: Int
    var west: Int
}
