//
//  LocationHelper.swift
//  WeatherAppTest
//
//  Created by Stepan Chegrenev on 25.03.2018.
//  Copyright © 2018 Stepan Chegrenev. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    var latitude: String?
    var longitude: String?
    var locationManager: CLLocationManager!
    
    var location: CLLocation! {
        didSet {
            latitude = "\(location.coordinate.latitude)"
            longitude = "\(location.coordinate.longitude)"
        }
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
        locationManager.startUpdatingLocation()
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("Unauthorized to use location service")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = (locations).last
        locationManager.stopUpdatingLocation()
    }
    
    
    
}
