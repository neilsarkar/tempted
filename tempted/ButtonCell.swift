//
//  ButtonCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

class ButtonCell : UICollectionViewCell {
    var timer: Timer?
    let releasedImage = UIImage(named: "LiveMosquitto")?.withRenderingMode(.alwaysOriginal)
    let pushedImage = UIImage(named: "DeadMosquitto")?.withRenderingMode(.alwaysOriginal)
    let infoImage = UIImage(named: "QuestionMark")?.withRenderingMode(.alwaysOriginal)
    var isPushed = false

    @IBOutlet weak var scrollHint: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle("", for: UIControlState())
        infoButton.setTitle("", for: UIControlState())
        infoButton.setImage(infoImage, for: UIControlState())
        showReleased()
        scrollHint.isHidden = true
        subscribe()
    }
    
    @IBAction func handleButtonTapped(_ sender: UIButton) {
        if( isPushed ) { return }
        isPushed = true
        showPushed()
        NotificationCenter.default.post(name: TPTNotification.CreateUrge, object: self)
    }
    
    private func subscribe() {
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self, selector: #selector(showReleased), name: TPTNotification.UrgeCreateFailed, object: nil)
    }
    
    internal func showPushed() {
        button.setImage(pushedImage, for: UIControlState())
        label.text = NSLocalizedString("saved.", comment: "Confirmation text after successful button press")
        label.textColor = UIColor.tmpGrey7DColor()
        scrollHint.isHidden = false
        infoButton.isHidden = true
        scrollHint.alpha = 0.0

        timer = Timer.scheduledTimer(timeInterval: TPTInterval.Respawn, target: self, selector: #selector(showReleased as (Void) -> Void), userInfo: nil, repeats: false)

        DispatchQueue.main.async(execute: {
            UIView.transition(with: self.label, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.label.textColor = UIColor.tmpGreyd5Color()
            }, completion: nil)
            
            UIView.animate(withDuration: TPTInterval.PushReaction, animations: {
                self.scrollHint.alpha = 1.0
            }, completion: nil)

        })
    }

    internal func showReleased() {
        let wasPushed = isPushed
        let defaultText = NSLocalizedString("catch a habit", comment: "Onboarding text to contextualize main button press")
        
        isPushed = false
        label.text = defaultText
        scrollHint.isHidden = true
        infoButton.isHidden = false

        if( wasPushed ) {
            DispatchQueue.main.async(execute: {
                UIView.transition(with: self.label, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.label.text = defaultText
                }, completion: nil)
                
                UIView.transition(with: self.button, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.button.setImage(self.releasedImage, for: UIControlState())
                }, completion: nil)                
            })
        } else {
            self.label.text = defaultText
            self.button.setImage(self.releasedImage, for: UIControlState())
        }
    }
}
