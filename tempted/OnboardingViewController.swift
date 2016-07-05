//
//  OnboardingViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 27/06/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit

class OnboardingViewController : UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // http://stackoverflow.com/questions/26835944/uitextview-text-content-doesnt-start-from-the-top
        textView.setContentOffset(CGPoint.zero, animated:false)
    }
}
