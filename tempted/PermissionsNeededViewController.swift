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
        switch(reason!) {
        case TPTString.LocationReason:
            labelText = TPTString.LocationPermissionsWarning
            break;
        case TPTString.PhotoReason:
            labelText = TPTString.PhotoPermissionsWarning
            break;
        default:
            labelText = "Sorry, something went wrong when checking permissions."
        }
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissSelf), name: TPTNotification.MapPermissionsGranted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkPermissions), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc internal func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func checkPermissions() {
        switch(reason!) {
        case TPTString.LocationReason:
            if( CLLocationManager.locationServicesEnabled() &&
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse ) {
                dismissSelf()
            }
            break;
        case TPTString.PhotoReason:
            if( AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized ) {
                dismissSelf()
            }
            break;
        default:
            Crashlytics.sharedInstance().recordError(NSError(domain: "tempted", code: 69, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Unknown permissions reason. Not dismissing", comment: "nope")
            ]))

            print("Unknown Reason! Not dismissing")
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        UIApplication.shared.openURL(appSettings!)
    }
}
