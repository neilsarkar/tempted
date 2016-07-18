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

// TODO: refactor this to use inheritance instead of just copying the other thing
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

    @IBAction func handleDelete(_ sender: AnyObject) {
        NotificationCenter.default().post(name: Notification.Name(rawValue: TPTNotification.UrgeDeleted), object: self, userInfo: ["id": urge.id])
    }
    
    @IBAction func retryTapped(_ sender: UIButton) {
        // TODO: should be no need to specify main thread
        DispatchQueue.main.async {
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
                DispatchQueue.main.async {
                    self.showLoadFailed()
                }
                
                }, success: { image in
                    self.mapImageView.isOpaque = false
                    self.mapImageView.image = image
                    DispatchQueue.main.async {
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
        mapImageView.isHidden = true
        deleteButton.isHidden = true
        retryButton.isHidden = true
        mapLoadFailedLabel.isHidden = true
    }
    
    private func showLoaded() {
        loadingSpinner.stopAnimating()
        mapImageView.isHidden = false
        deleteButton.isHidden = false
    }
    
    private func showLoadFailed() {
        // TODO: should this use a different cell? is there a cleaner way of hiding one whole and showing the other?
        mapLoadFailedLabel.isHidden = false
        retryButton.isHidden = false
        loadingSpinner.stopAnimating()
    }
}
