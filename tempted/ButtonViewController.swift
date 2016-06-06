//
//  ButtonViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import CoreLocation

class ButtonViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    
    @IBAction func handleButtonTapped(sender: AnyObject) {
        let urge = Urge();
        
        // TODO: do this in initialization
        urge.createdAt = NSDate();
        if( latlng != nil ) {
            urge.lat = latlng.latitude.description
            urge.lng = latlng.latitude.description
        }
        
        let realm = try! Realm()

        try! realm.write {
            realm.add(urge);
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("Listening")
        } else {
            print("Location services not enabled")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

