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
    var permissions: Permissions!
    
    override init() {
        super.init()

        locationManager = LocationManager()
        photoTaker = PhotoTaker()
        permissions = Permissions()
    }
    
    func save(cb: (NSError?) -> Void) {
        return cb(TPTError.MapPermissionsNotDetermined)
        if( !permissions.hasPhoto() ) {
            if( permissions.canRequestPhoto() ) {
                return cb(TPTError.PhotoPermissionsNotDetermined)
            } else {
                return cb(TPTError.PhotoPermissionsDeclined)
            }
        }
        
        if( !permissions.hasLocation() ) {
            if( permissions.canRequestLocation() ) {
                return cb(TPTError.MapPermissionsNotDetermined)
            } else {
                cb(TPTError.MapPermissionsDeclined)
                return
            }
        }
        
        photoTaker.takePhotos({err, selfieData, rearData in
            if( err != nil ) {
                // if there's an error, just throw out our PhotoTaker and spin up a new one
                self.photoTaker = PhotoTaker()
                return cb(err)
            }
            
            // TODO: only do UI work on the main thread -- https://github.com/realm/realm-cocoa/issues/1445
            dispatch_async(dispatch_get_main_queue(), {
                let urge = Urge();
                
                urge.createdAt = NSDate();
                let uuid = NSUUID().UUIDString
                urge.id = uuid
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

                
                NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreated, object: self)
            })
        })
    }
    
    func requestPhotoPermissions() {
        photoTaker.requestPermissions()
    }
    
    func requestMapPermissions() {
        locationManager.requestPermissions()
    }
}