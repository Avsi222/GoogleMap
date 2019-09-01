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
import RealmSwift
import Realm

class MapViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var mapView: GMSMapView?
    
    // Local variables
    var locationManager: LocationManager = LocationManager.instance
    let coordinate = CLLocationCoordinate2D(latitude: 55.878626, longitude: 37.719)
    var beginBackgruondTask: UIBackgroundTaskIdentifier?
    var routePath: GMSMutablePath?
    var route: GMSPolyline?
    var isTracking:Bool = false /// Флаг включен ли трэк
    var routeArray = [CLLocation]()
    var userMarker:GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
    }
    
    func configureLocationManager(){
        locationManager.location.asObservable().bind { [weak self] location in
            guard let location = location else { return }
            self?.routePath?.add(location.coordinate)
            self?.route?.path = self?.routePath
            self?.addPinToMap(location: location)
            self?.moveCamera(location: location)
            if self!.isTracking{
                self?.saveToArrayLocation(location: location)
            }
             
        }
    }
    
    func configureTimer(){
        beginBackgruondTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let strongSelf = self?.beginBackgruondTask else { return }
            UIApplication.shared.endBackgroundTask(strongSelf)
        })
    }
    
    func configureMap(){
        let camera = GMSCameraPosition.init(target: coordinate, zoom: 17)
        mapView?.camera = camera
        userMarker = GMSMarker(position: coordinate)
    }
    
    func moveCamera(location:CLLocation){
        let camera = GMSCameraPosition.init(target: location.coordinate, zoom: 17)
        mapView?.camera = camera
    }
    
    func addPinToMap(location:CLLocation){
        guard let image = DataManager().getSavedImage(named: "myImage") else{ return }
        userMarker.position = location.coordinate
        userMarker.map = mapView
        userMarker.icon = image
        userMarker.iconView?.layer.cornerRadius = 15
    }

}

//Tracking
extension MapViewController{
    
    func startTracking(){
        locationManager.startUpdatingLocation()
        route = GMSPolyline()
        route?.strokeWidth = 3
        route?.strokeColor = .red
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func startTrackingFromBase(){
        
        let realm = try! Realm()
        let newPath = GMSMutablePath()
        let coordArray = realm.objects(RouteRealm.self).last
        for coord in coordArray!.locationArray{
            let coordinates = CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.long)
            print(coord.lat, coord.long)
            newPath.add(coordinates)
        }
        routePath = newPath
        route = GMSPolyline()
        route?.strokeWidth = 3
        route?.strokeColor = .red
        route?.map = mapView
        //locationManager.startUpdatingLocation()
        mapView?.camera = GMSCameraPosition(latitude: newPath.coordinate(at: 1).latitude, longitude: newPath.coordinate(at: 1).longitude, zoom: 17)
        isTracking = true
    }
    
    func stopTracking(){
        locationManager.stopUpdatingLocation()
        saveToBaseLocation(locationArray: routeArray)
        clearTrack()
        isTracking = false
    }
    
    //очищаем маршрут
    func clearTrack(){
         routeArray.removeAll()
         route?.map = nil
    }
    
    func checkTracking(){
        if isTracking{
            let alert = UIAlertController(title: "Подождите", message: "Остановить трэк", preferredStyle: .alert)
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                self?.stopTracking()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//IBActions
extension MapViewController{
    @IBAction func startTrack(_ sender: UIButton){
        clearTrack()
        startTracking()
    }
    
    @IBAction func stopTrack(_ sender: UIButton){
        stopTracking()
    }
    
    @IBAction func previouslyRoute(_ sender: UIButton){
        checkTracking()
        startTrackingFromBase()
    }
    
}

// Work with base

extension MapViewController{
    
    func saveToArrayLocation(location:CLLocation){
        routeArray.append(location)
    }
    
    func saveToBaseLocation(locationArray:[CLLocation]){
        
        let realm = try! Realm()
        
        let routeCoord = RouteRealm()
        routeCoord.name = "Маршрут"
        
        for locCoord in locationArray{
            let lat = locCoord.coordinate.latitude
            let long = locCoord.coordinate.longitude
            let coord = Coordinates(long: long, lat: lat)
            //let coord = Coordinates()
            //coord.lat = locCoord.coordinate.latitude
            //coord.long = locCoord.coordinate.longitude
            try! realm.write {
                
                realm.add(coord)
            }
            print(coord)
            routeCoord.locationArray.append(coord)
        }
        print(routeCoord.locationArray)
        try! realm.write {
            
            realm.add(routeCoord)
        }
    }
}
