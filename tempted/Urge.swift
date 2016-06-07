//
//  Urge.swift
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
    dynamic var lat = 0.0
    dynamic var lng = 0.0
    dynamic var mapFile = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["createdAt", "id"]
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func mapImageUrl(width: Int, height: Int) -> NSURL? {
        let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat)+\(lng)&zoom=15&size=\(width)x\(height)&sensor=false&markers=\(lat)+\(lng)"
        return NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }
    
    func humanTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, h:mm a"
        
        return formatter.stringFromDate(createdAt)
    }
}
