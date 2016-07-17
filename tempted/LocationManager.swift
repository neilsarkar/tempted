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
        subscribe()

        if( canCaptureLocation() ) {
            captureLocation()
        }
    }

    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch(status) {
        case .AuthorizedWhenInUse:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.MapPermissionsGranted, object: self)
            captureLocation()
            break
        case .NotDetermined:
            break
        default:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorNoMapPermissions, object: self)
        }
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
    
    private func canCaptureLocation() -> Bool {
        if( !CLLocationManager.locationServicesEnabled() ) { return false }
        return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
    }
}