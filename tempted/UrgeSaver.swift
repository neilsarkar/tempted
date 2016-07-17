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
    
    // TODO: refactor service object that deals with getting permissions for both location and photos
    override init() {
        super.init()
        subscribe()

        locationManager = LocationManager()
        photoTaker = PhotoTaker()
    }
    
    func save() {
        photoTaker.takePhotos({err, selfieData, rearData in
            if( err != nil ) {
                // if there's an error, just throw out our PhotoTaker and spin up a new one
                self.photoTaker = PhotoTaker()
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreateFailed, object: self, userInfo: [
                        "err": err!
                    ])
                })
                if( err?.code != TPTError.PhotoNoPermissions.code ) {
                    print(err)
                    Crashlytics.sharedInstance().recordError(err!)
                }
                return
            }
            
            // TODO: only do UI work on the main thread -- https://github.com/realm/realm-cocoa/issues/1445
            dispatch_async(dispatch_get_main_queue(), {
                let urge = Urge();
                
                // TODO: do this in initialization
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
                    print(err)
                    Crashlytics.sharedInstance().recordError(err)
                    NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreateFailed, object: self, userInfo: [
                        "err": err
                    ])
                }

                
                NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreated, object: self)
            })
        })
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(save), name: TPTNotification.CreateUrge, object: nil)
    }
}