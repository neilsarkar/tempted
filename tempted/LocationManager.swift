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
    
    func locationManager(_ manager: CLLocationManager, didUpdate locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch(status) {
        case .authorizedWhenInUse:
            NotificationCenter.default.post(name: TPTNotification.MapPermissionsGranted, object: self)
            captureLocation()
            break
        case .notDetermined:
            break
        default:
            NotificationCenter.default.post(name: TPTNotification.ErrorNoMapPermissions, object: self)
        }
    }

    internal func handleForeground(_ note: Notification) {
        if( canCaptureLocation() ) {
            captureLocation()
        }
    }
    
    private func subscribe() {
        let noteCenter = NotificationCenter.default

        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    private func captureLocation() {
        if( isCapturingLocation ) { return }
        isCapturingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    private func canCaptureLocation() -> Bool {
        if( !CLLocationManager.locationServicesEnabled() ) { return false }
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
}
