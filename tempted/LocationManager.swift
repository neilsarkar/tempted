//
//  LocationManager.swift
//  tempted
//
//  Created by Neil Sarkar on 16/07/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import CoreLocation
import UIKit
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    var isCapturingLocation = false
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()

        let authStatus = CLLocationManager.authorizationStatus()
        switch(authStatus) {
        case .AuthorizedWhenInUse:
            captureLocation()
            break
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            notifyLocationStatus(authStatus)
        }
        subscribe()
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

    internal func handleForeground(note: NSNotification) {
        captureLocation()
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()

        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
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
        }
    }
    
    private func notifyLocationStatus(status: CLAuthorizationStatus) {
        print("notifying location status", status)
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

// location should always try to cache position when initialized if it has perms
// location should always try to cache position when foregrounded if it has perms
// location should always try to cache position when perms are granted

// location should not notify twice that there are no perms

// location should notify when permissions are declined
// location should notify when permissions are revoked
// location should notify when foregrounded and it has no permissions
// location should notify when permissions are