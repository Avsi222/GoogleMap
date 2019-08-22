//
//  Location.swift
//  MapProject
//
//  Created by Арсений Дорогин on 22/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

final class LocationManager: NSObject{
    static let instance = LocationManager()
    
    let locationManager = CLLocationManager()
    let location: Variable<CLLocation?> = Variable(nil)
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    func configureLocationManager(){
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true //разрешить обновление в background
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges() // для отслеживания занчимых изменений
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //locationManager.pausesLocationUpdatesAutomatically = false //Для постоянного остлеживания
    }
    
    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location.value = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
