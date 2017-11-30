//
//  LocationPermsViewController.swift
//  Tempted
//
//  Created by Neil Sarkar on 30/11/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit

class LocationPermsViewController : UIViewController {
    var permissionNeeded: String?
    var permissions: Permissions!
    var locationManager: LocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        permissions = Permissions()
        locationManager = LocationManager()
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if( permissions.hasLocation() ) {
            return loadNext()
        }
    }
    
    @IBAction func requestPerms(_ sender: Any) {
        if( permissions.hasLocation() ) {
            return loadNext()
        }
        if( !permissions.canRequestLocation() ) {
            return appealDecision()
        }

        locationManager.requestPermissions()
    }

    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadNext), name: TPTNotification.MapPermissionsGranted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appealDecision), name: TPTNotification.ErrorNoMapPermissions, object: nil)
    }
    
    @objc private func loadNext() {
        self.performSegue(withIdentifier: "nextSegue", sender: self)
    }
    
    @objc private func appealDecision() {
        self.permissionNeeded = TPTString.LocationReason
        self.performSegue(withIdentifier: "permissionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if( segue.destination.isKind(of: PermissionsNeededViewController.self) ) {
            let vc = segue.destination as! PermissionsNeededViewController
            vc.reason = permissionNeeded!
        }
    }

}
