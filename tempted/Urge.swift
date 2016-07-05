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

    // TODO: use data properties directly
    dynamic var photoFile=""
    dynamic var selfieFile=""
    
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
        formatter.dateFormat = "h:mm a"
        
        return formatter.stringFromDate(createdAt)
    }
    
    func humanDay() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.stringFromDate(createdAt)
    }
    
    func debugId() -> String {
        return id.componentsSeparatedByString("-")[0]
    }
    
    func isNight() -> Bool {
        // TODO: do this without converting to a string
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH"

        return Int(formatter.stringFromDate(createdAt)) >= 20
    }
    
    static func migrate() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            
            migrationBlock: { migration, oldSchemaVersion in
                if( oldSchemaVersion < 1 ) {
                    migration.enumerate(Urge.className()) { oldObject, newObject in
                        let oldId = oldObject!["id"]
                        newObject!["id"] = oldId == nil ? NSUUID().UUIDString : oldId
                    }
                }
                
                if( oldSchemaVersion < 3 ) {
                    migration.enumerate(Urge.className()) { oldObject, newObject in
                        newObject!["photoFile"] = ""
                        newObject!["selfieFile"] = ""
                    }
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
    }
}
