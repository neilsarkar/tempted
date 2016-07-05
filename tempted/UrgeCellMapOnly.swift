//
//  UrgeCellMapOnly.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import Crashlytics
import Haneke

// FIXME: refactor this to use inheritance instead of just copying the other thing
class UrgeCellMapOnly : UICollectionViewCell {
    var urge: Urge! {
        didSet { render() }
    }
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mapLoadFailedLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBAction func handleDelete(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeDeleted, object: self, userInfo: ["id": urge.id])
    }
    
    @IBAction func retryTapped(sender: UIButton) {
        // TODO: should be no need to specify main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.showLoading()
        }
        attemptLoadMapImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showLoading()
        
        loadingSpinner.hidesWhenStopped = true
    }
    
    private func render() {
        attemptLoadMapImage()
        timeLabel.text = urge.humanDay() + ", " + urge.humanTime()
    }
    
    private func attemptLoadMapImage() {
        if let mapUrl = urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height)) {
            mapImageView.hnk_setImageFromURL(mapUrl, failure: { error in
                if( error?.code != -1009 ) {
                    print("Unknown error", error)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.showLoadFailed()
                }
                
                }, success: { image in
                    self.mapImageView.opaque = false
                    self.mapImageView.image = image
                    dispatch_async(dispatch_get_main_queue()) {
                        self.showLoaded()
                    }
            })
        } else {
            print("Invalid map URL", urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height)))
        }
    }
    
    // MARK: interface state changes
    
    private func showLoading() {
        loadingSpinner.startAnimating()
        mapImageView.hidden = true
        deleteButton.hidden = true
        retryButton.hidden = true
        mapLoadFailedLabel.hidden = true
    }
    
    private func showLoaded() {
        loadingSpinner.stopAnimating()
        mapImageView.hidden = false
        deleteButton.hidden = false
    }
    
    private func showLoadFailed() {
        // TODO: should this use a different cell? is there a cleaner way of hiding one whole and showing the other?
        mapLoadFailedLabel.hidden = false
        retryButton.hidden = false
        loadingSpinner.stopAnimating()
    }
}
