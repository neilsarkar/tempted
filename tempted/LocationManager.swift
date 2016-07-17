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
        subscribe()
        processState()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        processState()
    }

    internal func handleForeground(note: NSNotification) {
        if( canCaptureLocation() ) {
            captureLocation()
        }
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()

        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    private func captureLocation() {
        if( isCapturingLocation ) { return }
        isCapturingLocation = true
        locationManager.startUpdatingLocation()
    }

    private func processState() {
        if( !CLLocationManager.locationServicesEnabled() ) {
            return NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
        }
        
        let status = CLLocationManager.authorizationStatus()

        switch(status) {
        case .AuthorizedWhenInUse:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.MapPermissionsGranted, object: self)
            break
        case .Denied:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorNoMapPermissions, object: self)
            return
        case .Restricted:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
            return
        default:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
            return
        }
        
        captureLocation()
    }
    
    private func canCaptureLocation() -> Bool {
        if( !CLLocationManager.locationServicesEnabled() ) { return false }
        return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }
}