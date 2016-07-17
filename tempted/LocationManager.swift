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
        // TODO: probably shouldn't do this
        captureLocation()
        subscribe()
    }

    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("auth status changed to", status)
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
            print("notifying with location services disabled")
            return NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        if( authStatus == .AuthorizedWhenInUse) {
            isCapturingLocation = true
            locationManager.startUpdatingLocation()
        } else {
            print("notifying location status from capture location")
            notifyLocationStatus(authStatus)
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
