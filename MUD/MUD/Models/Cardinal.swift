//
//  Direction.swift
//  MUD
//
//  Created by Jordan Christensen on 3/5/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import Foundation

enum Direction: String {
    case north = "n"
    case south = "s"
    case east = "e"
    case west = "w"
}

struct Cardinal: Codable {
    var direction: String
}
