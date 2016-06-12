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
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showLoading()
        loadingSpinner.hidesWhenStopped = true
    }
    
    // is this the right place to do this display logic
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: skip this unless it's the final layout
        
        if (urge == nil) {
            NSLog("Urge not found for UrgeCell")
            return
        }

        stopLoading()
        mapImageView.opaque = false
        mapImageView.hnk_setImageFromURL(urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height))!)
    }

    private func showLoading() {
        loadingSpinner.startAnimating()
        mapImageView.hidden = true
        deleteButton.hidden = true
    }
    
    private func stopLoading() {
        loadingSpinner.stopAnimating()
        mapImageView.hidden = false
        deleteButton.hidden = false
    }
}
