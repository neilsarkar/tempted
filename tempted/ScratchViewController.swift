//
//  ScratchViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/10/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import Haneke // unnecessary?

class ScratchViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        imageView.backgroundColor = UIColor.magentaColor()
        imageView.contentMode = .ScaleAspectFill

        
//        let constraint = NSLayoutConstraint(
//            item: imageView,
//            attribute: .Height,
//            relatedBy: .Equal,
//            toItem: self.view,
//            attribute: .Height,
//            multiplier: 0.5,
//            constant: 0
//        )
//        imageView.addConstraint(constraint)
//        imageView.addConstraint(constraint)
//        imageView.imageViewTop
//        imageView.removeConstraint(
//        imageView.translatesAutoresizingMaskIntoConstraints = true
//        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.width, 10)
    }
}
