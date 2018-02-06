//
//  AppManager.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import CoreLocation

class AppManager: NSObject {
    
    
    static let sharedInstance = AppManager()
    var myLocation = CLLocation(latitude: 0, longitude: 0)

    var shootArray: Array<ShootModel> = []
   
    override init() {
        super.init()
        
    }
    
    func setFirstTime(isfirst:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(isfirst, forKey: KUserDefaultFirst)
        defaults.synchronize()
    }
    
    func getFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        let _isfirst = defaults.bool(forKey: KUserDefaultFirst)
        return _isfirst;
    }
    
    func setNotificationSetting(notification:Bool) {
        let defaults = UserDefaults.standard
        defaults.set(notification, forKey: KUserDefaultNotification)
        defaults.synchronize()
    }
    func getNotificationSetting()->Bool{
        let defaults = UserDefaults.standard
        let _notification = defaults.bool(forKey: KUserDefaultFirst)
        return _notification;
    }
    
    func getCounts(year: Int, month: Int, killed: Bool)->Int {
        
        let seldate = String.init(format: "%d-%02d", year, month)
        var count: Int = 0;
        
        if killed {
            for i in 0..<shootArray.count {
                let shoot = shootArray[i]
                if shoot.incident_date.contains(seldate) {
                    count += shoot.killed
                }
            }
        }
        else {
            for i in 0..<shootArray.count {
                let shoot = shootArray[i]
                if shoot.incident_date.contains(seldate) {
                    count += shoot.injured
                }
            }
        }
        
        return count;
    }
}
