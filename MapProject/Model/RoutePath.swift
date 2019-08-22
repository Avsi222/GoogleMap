//
//  RoutePath.swift
//  MapProject
//
//  Created by Арсений Дорогин on 14/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import Realm
import RealmSwift
import UIKit
import CoreLocation

class RouteRealm: Object{
    dynamic var name = ""
    let locationArray = List<Coordinates>()
}

class Coordinates: Object {
    dynamic var long: Double = 0
    dynamic var lat: Double = 0
    
   convenience init(long:Double,lat:Double) {
        self.init()
        self.long = long
        self.lat = lat
    }
}
