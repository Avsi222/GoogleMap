//
//  ViewController.swift
//  MapProject
//
//  Created by Арсений Дорогин on 05/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView:GMSMapView?
    var locationManager:CLLocationManager!
    let coordinate = CLLocationCoordinate2D(latitude: 55.878626, longitude: 37.719)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }
    
    func configureMap(){
        let camera = GMSCameraPosition.init(target: coordinate, zoom: 17)
        mapView?.camera = camera
    }
    
    func configureLocationManager(){
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    func moveCamera(location:CLLocation){
        let camera = GMSCameraPosition.init(target: location.coordinate, zoom: 17)
        mapView?.camera = camera
    }
    
    func addPinToMap(location:CLLocation){
        let marker = GMSMarker(position: location.coordinate)
        marker.map = mapView
    }

}

extension MapViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(coordinate)
        addPinToMap(location: location)
        moveCamera(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

