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
    var isPushed = false

    @IBOutlet weak var scrollHint: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle("", forState: .Normal)
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
        timer = NSTimer.scheduledTimerWithTimeInterval(TPTInterval.Respawn, target: self, selector: #selector(showReleased), userInfo: nil, repeats: false)
        scrollHint.hidden = false
    }
    
    internal func showReleased() {
        isPushed = false
        button.setImage(releasedImage, forState: UIControlState.Normal)
        label.text = NSLocalizedString("craving that thing?", comment: "Onboarding text to contextualize main button press")
    }
}
