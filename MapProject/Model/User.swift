//
//  User.swift
//  MapProject
//
//  Created by Арсений Дорогин on 14/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import RealmSwift

class User: Object{
    @objc dynamic var login: String = ""
    @objc dynamic var passsword: String = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
