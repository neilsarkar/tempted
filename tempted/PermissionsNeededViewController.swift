//
//  PermissionsNeededViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/12/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class PermissionsNeededViewController : UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var settingsButton: UIButton!

    var appSettings: URL?
    var labelText: String?

    var reason: String? {
        didSet { setLabelText() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribe()
        appSettings = URL(string: UIApplicationOpenSettingsURLString)

        if( appSettings == nil ) {
            settingsButton.isHidden = true
        }
        
        if( labelText != nil ) {
            label.text = labelText
        }
    }
    
    func setLabelText() {
        if( reason == TPTString.LocationReason ) {
            labelText = TPTString.LocationPermissionsWarning
        } else if( reason == TPTString.PhotoReason ) {
            labelText = TPTString.PhotoPermissionsWarning
        }
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSelf), name: TPTNotification.MapPermissionsGranted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissions), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    internal func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func checkPermissions() {
        if( reason == TPTString.PhotoReason ) {
            if( AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized ) {
                dismissSelf()
            }
        } else if( reason == TPTString.LocationReason ) {
            if( CLLocationManager.locationServicesEnabled() &&
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse ) {
                dismissSelf()
            }
        } else {
            print("Unknown Reason! Not dismissing")
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        UIApplication.shared.openURL(appSettings!)
    }
}
