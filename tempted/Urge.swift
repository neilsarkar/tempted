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
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["createdAt", "id"]
    }
    
    func mapImageUrl(width: Int, height: Int) -> NSURL? {
        let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat)+\(lng)&size=\(width*2)x\(height*2)&sensor=false&markers=\(lat)+\(lng)"
        return NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }
    
    func photoImageUrl(width: Int, height: Int) -> NSURL? {
        let str = "https://placeholdit.imgix.net/~text?txtsize=30&txt=Front+Photo&w=\(width*2)&h=\(height*2)"
        return NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }

    func selfieImageUrl(width: Int, height: Int) -> NSURL? {
        let str = "https://placeholdit.imgix.net/~text?txtsize=30&txt=Selfie&w=\(width*2)&h=\(height*2)"
        return NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
    }

    func humanTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, h:mm a"
        
        return formatter.stringFromDate(createdAt)
    }
    
    static func migrate() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            
            migrationBlock: { migration, oldSchemaVersion in
                if( oldSchemaVersion < 1 ) {
                    migration.enumerate(Urge.className()) { oldObject, newObject in
                        let oldId = oldObject!["id"]
                        newObject!["id"] = oldId == nil ? NSUUID().UUIDString : oldId
                    }
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
    }
}
