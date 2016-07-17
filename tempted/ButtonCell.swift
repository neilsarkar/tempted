//
//  ButtonCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

class ButtonCell : UICollectionViewCell {
    var timer: NSTimer?
    let releasedImage = UIImage(named: "LiveMosquitto")?.imageWithRenderingMode(.AlwaysOriginal)
    let pushedImage = UIImage(named: "DeadMosquitto")?.imageWithRenderingMode(.AlwaysOriginal)
    let infoImage = UIImage(named: "QuestionMark")?.imageWithRenderingMode(.AlwaysOriginal)
    var isPushed = false

    @IBOutlet weak var scrollHint: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle("", forState: .Normal)
        infoButton.setTitle("", forState: .Normal)
        infoButton.setImage(infoImage, forState: .Normal)
        showReleased()
        scrollHint.hidden = true
        subscribe()
    }
    
    @IBAction func handleButtonTapped(sender: UIButton) {
        if( isPushed ) { return }
        isPushed = true
        showPushed()
        NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.CreateUrge, object: self)
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(showReleased), name: TPTNotification.UrgeCreateFailed, object: nil)
    }
    
    internal func showPushed() {
        button.setImage(pushedImage, forState: .Normal)
        label.text = NSLocalizedString("saved.", comment: "Confirmation text after successful button press")
        label.textColor = UIColor.tmpGrey7DColor()
        scrollHint.hidden = false
        infoButton.hidden = true
        scrollHint.alpha = 0.0

        timer = NSTimer.scheduledTimerWithTimeInterval(TPTInterval.Respawn, target: self, selector: #selector(showReleased as Void -> Void), userInfo: nil, repeats: false)

        dispatch_async(dispatch_get_main_queue(), {
            UIView.transitionWithView(self.label, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.label.textColor = UIColor.tmpGreyd5Color()
            }, completion: nil)
            
            UIView.animateWithDuration(TPTInterval.PushReaction, animations: {
                self.scrollHint.alpha = 1.0
            }, completion: nil)

        })
    }

    internal func showReleased() {
        let wasPushed = isPushed
        let defaultText = NSLocalizedString("catch a habit", comment: "Onboarding text to contextualize main button press")
        
        isPushed = false
        label.text = defaultText
        scrollHint.hidden = true
        infoButton.hidden = false

        if( wasPushed ) {
            dispatch_async(dispatch_get_main_queue(), {
                UIView.transitionWithView(self.label, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.label.text = defaultText
                }, completion: nil)
                
                UIView.transitionWithView(self.button, duration: TPTInterval.PushReaction, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.button.setImage(self.releasedImage, forState: .Normal)
                }, completion: nil)                
            })
        } else {
            self.label.text = defaultText
            self.button.setImage(self.releasedImage, forState: .Normal)
        }
    }
}
