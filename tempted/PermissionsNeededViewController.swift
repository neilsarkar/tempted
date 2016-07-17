//
//  PermissionsNeededViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/12/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

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
    }
    
    internal func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func settingsButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(appSettings!)
    }
}
