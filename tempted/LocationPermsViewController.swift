//
//  LocationPermsViewController.swift
//  Tempted
//
//  Created by Neil Sarkar on 30/11/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit


class LocationPermsViewController : UIViewController {

    @IBAction func requestPerms(_ sender: Any) {
        self.performSegue(withIdentifier: "permissionSegue", sender: self)
    }
}
