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


class UrgeSaver: NSObject, CLLocationManagerDelegate {
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!

    override init() {
        super.init()
        subscribe()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        self.captureLocation()
    }
    
    func save() {
        let urge = Urge();
        
        // TODO: do this in initialization
        urge.createdAt = NSDate();
        let uuid = NSUUID().UUIDString
        urge.id = uuid
        if( latlng != nil ) {
            urge.lat = latlng.latitude
            urge.lng = latlng.longitude
            // TODO: remove mapFile
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(urge);
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreated, object: nil)
    }
    
    internal func handleForeground(note: NSNotification) {
        captureLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        noteCenter.addObserver(self, selector: #selector(save), name: TPTNotification.CreateUrge, object: nil)
    }
    
    private func captureLocation() {
        if( CLLocationManager.locationServicesEnabled() ) {
            locationManager.startUpdatingLocation()
            print("Starting to capture location")
        } else {
            print("Location services not enabled")
        }
    }
}