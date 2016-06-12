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

        appSettings = NSURL(string: UIApplicationOpenSettingsURLString)

        if( appSettings == nil ) {
            settingsButton.hidden = true
        }
    }
    
    @IBAction func settingsButtonTapped(sender: UIButton) {
        UIApplication.sharedApplication().openURL(appSettings!)
    }
}
