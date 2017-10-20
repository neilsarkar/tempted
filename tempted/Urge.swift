//
//  Urge.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import RealmSwift

class Urge:RealmSwift.Object {
    dynamic var id=""
    dynamic var createdAt = Date(timeIntervalSince1970: 1)
    dynamic var photo: Data? = nil
    dynamic var selfie: Data? = nil
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
    
    func mapImageUrl(_ width: Int, height: Int) -> URL? {
        let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat)+\(lng)&size=\(width*2)x\(height*2)&sensor=false&markers=\(lat)+\(lng)"
        return URL(string: str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    }
    
    func humanTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: createdAt)
    }
    
    func humanDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: createdAt)
    }
    
    func debugId() -> String {
        return id.components(separatedBy: "-")[0]
    }
    
    func isNight() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"

        let hour = Int(formatter.string(from: createdAt))!
        return hour <= 6 || hour >= 20
    }
    
    static func migrate() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            
            migrationBlock: { migration, oldSchemaVersion in
                if( oldSchemaVersion < 1 ) {
                    migration.enumerateObjects(ofType: Urge.className(), { oldObject, newObject in
                        let oldId = oldObject!["id"]
                        newObject!["id"] = oldId == nil ? UUID().uuidString : oldId
                    })
                }
                
                if( oldSchemaVersion < 3 ) {
                    migration.enumerateObjects(ofType: Urge.className(), { oldObject, newObject in
                        newObject!["photoFile"] = ""
                        newObject!["selfieFile"] = ""
                    })
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
    }
}
