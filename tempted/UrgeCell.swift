//
//  UrgeCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

class UrgeCell : UICollectionViewCell {
    var urgeId = ""
    
    
    @IBAction func handleDelete(sender: AnyObject) {
        if( urgeId == "" ) { return print("UrgeID not set!") }
        NSNotificationCenter.defaultCenter().postNotificationName("Delete Urge", object: self, userInfo: ["id": urgeId])
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!

    @IBOutlet weak var deleteButton: UIButton!
}
