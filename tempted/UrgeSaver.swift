//
//  UrgeSaver.swift
//  tempted
//
//  Created by Neil Sarkar on 6/11/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import UIKit
import AVFoundation

class UrgeSaver: NSObject, CLLocationManagerDelegate {
    // TODO: refactor location service that deals with capturing location
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    var isCapturingLocation = false
    
    var photoTaker: PhotoTaker!
    
    // TODO: refactor service object that deals with getting permissions for both location and photos
    
    
    override init() {
        super.init()
        subscribe()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        photoTaker = PhotoTaker()
        captureLocation()
    }
    
    func save() {
        photoTaker.takePhotos({err, selfieData, photoData in
            if( err != nil ) {
//              TODO: report to crashlytics
                print(err)
                // if there's an error, just throw out our PhotoTaker and spin up a new one
                self.photoTaker = PhotoTaker()
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreateFailed, object: self)
                })
                return
            }
            
            // TODO: only do UI work on the main thread -- https://github.com/realm/realm-cocoa/issues/1445
            dispatch_async(dispatch_get_main_queue(), {
                let urge = Urge();
                
                // TODO: do this in initialization
                urge.createdAt = NSDate();
                let uuid = NSUUID().UUIDString
                urge.id = uuid
                if( self.latlng != nil ) {
                    urge.lat = self.latlng.latitude
                    urge.lng = self.latlng.longitude
                }
                
                if( selfieData != nil ) {
                    urge.selfie = selfieData
                }
                
                if( photoData != nil ) {
                    urge.photo = photoData
                }
                
                
                let realm = try! Realm()
                
                try! realm.write {
                    realm.add(urge);
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreated, object: self)
            })
        })
    }
    
    internal func handleForeground(note: NSNotification) {
        captureLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        notifyLocationStatus(status)
        if( status == .AuthorizedWhenInUse && latlng == nil ) {
            captureLocation()
        }
    }
    
    private func takePhotos(cb: (NSError?, selfieData: NSData?, photoData: NSData?) -> Void) {
        return cb(nil, selfieData: nil, photoData: nil)
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        noteCenter.addObserver(self, selector: #selector(save), name: TPTNotification.CreateUrge, object: nil)
    }
    
    private func captureLocation() {
        if( isCapturingLocation ) { return }
        
        if( !CLLocationManager.locationServicesEnabled() ) {
            return NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
        }

        let authStatus = CLLocationManager.authorizationStatus()
        if( authStatus == .AuthorizedWhenInUse) {
            isCapturingLocation = true
            locationManager.startUpdatingLocation()
        } else {
            notifyLocationStatus(authStatus)
        }
    }
    
    private func notifyLocationStatus(status: CLAuthorizationStatus) {
        switch(status) {
        case .Denied:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorNoMapPermissions, object: self)
            break
        case .Restricted:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
            break
        case .AuthorizedWhenInUse:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.MapPermissionsGranted, object: self)
            break
        default:
            return
        }
    }
}