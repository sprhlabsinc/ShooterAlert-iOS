//
//  LocationTracker.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    var mLocationManager: CLLocationManager = CLLocationManager()
    
    static let sharedInstance = LocationManager()
    
    override init() {
        super.init()
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        mLocationManager.delegate = self
        mLocationManager.requestAlwaysAuthorization()
    }
    
    func doLocationTrack() {
        mLocationManager.startUpdatingLocation()
    }
    func changeAccuracy(background isBackground:Bool) {
        if isBackground {
            mLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }else{
            mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
}
// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        AppManager.sharedInstance.myLocation = mostRecentLocation
        
        let location = ["location": mostRecentLocation]
        NotificationCenter.default.post(name: .updateLocation, object: nil, userInfo: location)
        
        if UIApplication.shared.applicationState == .active {
            changeAccuracy(background: false)
        } else {
            changeAccuracy(background: true)
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.createMenuView()
        }
    }
}

extension Notification.Name {
    static let updateLocation = Notification.Name("updateLocaton")
}
