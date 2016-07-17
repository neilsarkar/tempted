//
//  PermissionsNeededViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/12/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import AVFoundation

class PermissionsNeededViewController : UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var settingsButton: UIButton!

    var appSettings: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribe()
        appSettings = NSURL(string: UIApplicationOpenSettingsURLString)

        if( appSettings == nil ) {
            settingsButton.hidden = true
        }
    }
    
    private func subscribe() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dismiss), name: TPTNotification.MapPermissionsGranted, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkPermissions), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    internal func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func checkPermissions() {
        switch( AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ) {
        case .Authorized:
            dismiss()
            break
        case .NotDetermined:
            dismiss()
            break
        default: break
        }
    }
    
    @IBAction func settingsButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(appSettings!)
    }
}
