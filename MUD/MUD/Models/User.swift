//
//  User.swift
//  MUD
//
//  Created by Jordan Christensen on 3/3/20.
//  Copyright © 2020 Mazjap Co. All rights reserved.
//

import Foundation

struct UserLogin: Codable {
    var username: String
    var password: String
}

struct UserRegister: Codable {
    var username: String
    var email: String
    var password1: String
    var password2: String
}
