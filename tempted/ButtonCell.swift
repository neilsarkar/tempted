//
//  ButtonCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

class ButtonCell : UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    @IBAction func handleButtonTapped(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("Button Tapped", object: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let image = UIImage(named: "LiveMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        button.setTitle("", forState: UIControlState.Normal)
        button.setImage(image, forState: UIControlState.Normal)
        
        subscribe()
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(showPressed), name: "Button Tapped", object: nil)
    }
    
    @objc private func showPressed() {
        let image = UIImage(named: "DeadMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        button.setImage(image, forState: UIControlState.Normal)
    }
}
