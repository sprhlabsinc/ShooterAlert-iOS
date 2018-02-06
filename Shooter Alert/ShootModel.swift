//
//  InboxModel.swift
//  CannaCard
//
//  Created by developer on 5/13/17.
//  Copyright © 2017 Kristaps Kuzmins. All rights reserved.
//

import UIKit

class ShootModel: NSObject {
    
    var id: Int = -1
    var incident_date: String = ""
    var state: String = ""
    var city: String = ""
    var address: String = ""
    var killed: Int = 0
    var injured: Int = 0
    var url1: String = ""
    var url2: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var inside: Bool = false
    
    func initWithDictionary(data:Dictionary<String, AnyObject>){
        
        if let val = data["id"] {
           id = self.getNumberFromData(data: val)
        }
        if let val = data["incident_date"] as? String {
            incident_date = val
        }
        if let val = data["state"] as? String {
            state = val
        }
        if let val = data["city"] as? String {
            city = val
        }
        if let val = data["address"] as? String {
            address = val
        }
        if let val = data["killed"] {
            killed = self.getNumberFromData(data: val)
        }
        if let val = data["injured"] {
            injured = self.getNumberFromData(data: val)
        }
        if let val = data["url1"] as? String {
            url1 = val
        }
        if let val = data["url2"] as? String {
            url2 = val
        }
        if let val = data["latitude"] {
            latitude = self.getDoubleFromData(data: val)
        }
        if let val = data["longitude"] {
            longitude = self.getDoubleFromData(data: val)
        }
    }
}
