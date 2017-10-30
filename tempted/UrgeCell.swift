//
//  UrgeCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire
import AlamofireImage

class UrgeCell : UICollectionViewCell {
    var urge: Urge! {
        didSet { render() }
    }
    
    @IBAction func handleDelete(_ sender: AnyObject) {
        NotificationCenter.default.post(name: TPTNotification.UrgeDeleted, object: self, userInfo: ["id": urge.id])
    }
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mapLoadFailedLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeBGImageView: UIImageView!
    
    // TODO: don't use an entire view just to get padding
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBAction func retryTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.showLoading()
        }
        attemptLoadMapImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showLoading()
        
        container.layer.cornerRadius = 5.0
        container.layer.masksToBounds = false
        container.layer.borderWidth = 1.0
        container.layer.borderColor = UIColor.tmpWhiteFBColor().cgColor
        loadingSpinner.hidesWhenStopped = true
    }
    
    private func render() {
        attemptLoadMapImage()
        loadPhotos()
        timeLabel.text = urge.humanTime()
        dayLabel.text = urge.humanDay()
        if( urge.isNight() ) {
            timeBGImageView.image = UIImage(named: "NightBG")
        } else {
            timeBGImageView.image = UIImage(named: "DayBG")
        }
        // TODO: display debug label if debug build
        debugLabel.text = urge.id.components(separatedBy: "-")[0]
    }
    
    private func loadPhotos() {
        if( urge.photo != nil ) {
            self.photoImageView.isOpaque = false
            self.photoImageView.image = UIImage(data: urge.photo! as Data)
        }

        if( urge.selfie != nil ) {
            self.selfieImageView.isOpaque = false
            self.selfieImageView.image = UIImage(data: urge.selfie! as Data)
        }
    }
    
    private func attemptLoadMapImage() {
        guard let mapUrl = urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height)) else {
            Crashlytics.sharedInstance().recordError(NSError(domain: "tempted", code: 69, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Invalid map URL", comment: urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height))?.absoluteString ?? "unknown map URL")
            ]))
            
            print("Invalid map URL", urge.mapImageUrl(Int(mapImageView.frame.width), height: Int(mapImageView.frame.height))?.absoluteString ?? "unknown map URL")
            DispatchQueue.main.async {
                self.showLoadFailed()
            }
            return
        }

        Alamofire.request(mapUrl).responseImage { response in
            guard !response.result.isFailure else {
                if let err = response.result.error as NSError? {
                    // -1009: no internet
                    // -1200: ssl failed (might need wifi verification)
                    if( err.code != -1009 || err.code != -1200 ) {
                        Crashlytics.sharedInstance().recordError(err)
                    }
                } else {
                    Crashlytics.sharedInstance().recordError(response.result.error!)
                }

                DispatchQueue.main.async {
                    self.showLoadFailed()
                }

                return
            }

            guard let image = response.result.value else {
                Crashlytics.sharedInstance().recordError(NSError(domain: "tempted", code: 69, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Image is nil in UrgeCell", comment: "whatever")
                ]))
                
                DispatchQueue.main.async {
                    self.showLoadFailed()
                }
                
                return
            }

            debugPrint(response.result)
            self.mapImageView.isOpaque = false
            self.mapImageView.image = image
            DispatchQueue.main.async {
                self.showLoaded()
            }
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
