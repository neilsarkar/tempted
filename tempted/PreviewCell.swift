//
//  UrgeCell.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import Crashlytics

class PreviewCell : UICollectionViewCell {
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        loadingSpinner.startAnimating()
    }
}

