//
//  LocationPermsViewController.swift
//  Tempted
//
//  Created by Neil Sarkar on 30/11/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit

class LocationPermsViewController : UIViewController {
    var permissions: Permissions!
    var locationManager: LocationManager!
    var isTransitioning = false
    var unwinding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        permissions = Permissions()
        locationManager = LocationManager()
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if( !unwinding && permissions.hasLocation() ) {
            print("loading from viewDidAppear")
            return loadNext()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let noteCenter = NotificationCenter.default
        noteCenter.removeObserver(self)
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
        // this lock is necessary because didChangeAuthorizationStatus will fire along with
        // viewDidAppear in some cases but (possibly) not all
        if( isTransitioning ) { return }
        isTransitioning = true
        self.performSegue(withIdentifier: "nextSegue", sender: self)
    }
    
    @objc private func appealDecision() {
        self.performSegue(withIdentifier: "permissionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if( segue.destination.isKind(of: PermissionsNeededViewController.self) ) {
            let vc = segue.destination as! PermissionsNeededViewController
            vc.reason = TPTString.LocationReason
        }
    }

    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        self.unwinding = true
        return false
    }
}
