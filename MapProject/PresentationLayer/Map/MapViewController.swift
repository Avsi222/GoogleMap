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
    var locationManager: CLLocationManager!
    let coordinate = CLLocationCoordinate2D(latitude: 55.878626, longitude: 37.719)
    var beginBackgruondTask: UIBackgroundTaskIdentifier?
    var routePath: GMSMutablePath?
    var route: GMSPolyline?
    var isTracking:Bool = false /// Флаг включен ли трэк
    var routeArray = [CLLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configureLocationManager()
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
    }
    
    func configureLocationManager(){
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true //разрешить обновление в background
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges() // для отслеживания занчимых изменений
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //locationManager.pausesLocationUpdatesAutomatically = false //Для постоянного остлеживания
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
        //addPinToMap(location: location)
        routePath?.add(location.coordinate)
        route?.path = routePath
        moveCamera(location: location)
        if isTracking{
            saveToArrayLocation(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
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
            let coord = Coordinates(value: ["lat": lat,"long": long])
            //let coord = Coordinates()
            //coord.lat = locCoord.coordinate.latitude
            //coord.long = locCoord.coordinate.longitude
            print(coord)
            routeCoord.locationArray.append(coord)
        }
        print(routeCoord.locationArray)
        try! realm.write {
            
            realm.add(routeCoord)
        }
    }
}
