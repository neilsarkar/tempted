//
//  UrgeSaver.swift
//  tempted
//
//  Created by Neil Sarkar on 6/11/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import RealmSwift
import UIKit
import AVFoundation
import Crashlytics

class UrgeSaver: NSObject {
    var locationManager: LocationManager!
    var photoTaker: PhotoTaker!
    
    override init() {
        super.init()

        locationManager = LocationManager()
        photoTaker = PhotoTaker()
    }

    func save(_ cb: @escaping (NSError?) -> Void) {
        save([AnyHashable: Any](), cb)
    }
    
    func save(_ payload: [AnyHashable:Any], _ cb: @escaping (NSError?) -> Void) {
        photoTaker.takePhotos({err, selfieData, rearData in
            if( err != nil ) {
                // if there's an error, just throw out our PhotoTaker and spin up a new one
                self.photoTaker = PhotoTaker()
                return cb(err)
            }
            
            // TODO: only do UI work on the main thread -- https://github.com/realm/realm-cocoa/issues/1445
            DispatchQueue.main.async(execute: {
                let urge = Urge();
                
                urge.createdAt = Date();
                let uuid = UUID().uuidString
                urge.id = uuid
                if let viceId = payload["viceId"] as? Int {
                    urge.viceId = viceId
                }
                if( self.locationManager.latlng != nil ) {
                    urge.lat = self.locationManager.latlng.latitude
                    urge.lng = self.locationManager.latlng.longitude
                }
                
                if( selfieData != nil ) {
                    urge.selfie = selfieData
                }
                
                if( rearData != nil ) {
                    urge.photo = rearData
                }
                
                let realm = try! Realm()
                do {
                    try realm.write {
                        realm.add(urge)
                    }
                } catch let err as NSError {
                    return cb(err)
                }

                
                NotificationCenter.default.post(name: TPTNotification.UrgeCreated, object: self)
            })
        })
    }
}
