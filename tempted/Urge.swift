//
//  Dog.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import RealmSwift

class Urge:Object {
    dynamic var id=""
    dynamic var createdAt = NSDate(timeIntervalSince1970: 1)
    dynamic var photo: NSData? = nil
    dynamic var selfie: NSData? = nil
    dynamic var lat="39.833850"
    dynamic var lng="-8.437500"

    override static func indexedProperties() -> [String] {
        return ["createdAt"]
    }
    
    func humanTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, h:mm a"
        
        return formatter.stringFromDate(createdAt)
    }
}
