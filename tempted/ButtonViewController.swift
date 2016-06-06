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
        let image = UIImage(named: "DeadMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        button.setImage(image, forState: UIControlState.Normal)

        let urge = Urge();
        
        // TODO: do this in initialization
        urge.createdAt = NSDate();
        if( latlng != nil ) {
            urge.lat = latlng.latitude
            urge.lng = latlng.longitude
        }
        
        let realm = try! Realm()

        try! realm.write {
            realm.add(urge);
        }
        
    }

    @IBOutlet weak var button: UIButton!

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: do this better
        let image = UIImage(named: "LiveMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        button.setImage(image, forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not enabled")
        }
        
        button.setTitle("", forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

