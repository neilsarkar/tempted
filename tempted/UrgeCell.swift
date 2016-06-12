//
//  UrgeCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import Crashlytics
import Haneke

class UrgeCell : UICollectionViewCell {
    var urgeId = ""
    var urge: Urge!
    
    @IBAction func handleDelete(sender: AnyObject) {
        if( urgeId == "" ) { return print("UrgeID not set!") }
        NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeDeleted, object: self, userInfo: ["id": urgeId])
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!

    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: skip this unless it's the final layout
        
        // QUESTION: is this the right place for this?
        if (urge == nil) {
            NSLog("Urge not found for UrgeCell")
            return
        }

        mapImageView.opaque = false
        mapImageView.hnk_setImageFromURL(urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height))!)
    }
}
