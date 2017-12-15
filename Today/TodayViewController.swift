//
//  TodayViewController.swift
//  Today
//
//  Created by Neil Sarkar on 28/10/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var liquor: UIButton!
    @IBOutlet weak var smokes: UIButton!
    @IBOutlet weak var phone: UIButton!
    @IBOutlet weak var carbs: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        liquor.imageView?.contentMode = .scaleAspectFit
        smokes.imageView?.contentMode = .scaleAspectFit
        phone.imageView?.contentMode  = .scaleAspectFit
        carbs.imageView?.contentMode  = .scaleAspectFit
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if( activeDisplayMode == NCWidgetDisplayMode.compact ) {
            self.preferredContentSize = maxSize;
        } else {
            self.preferredContentSize = CGSize(width: 0, height: 400)
        }
    }
    
    @IBAction func touchBeer(_ sender: Any) {
        extensionContext?.open(URL(string: "tempted://urge/1")!)
    }
    
    @IBAction func touchSmoke(_ sender: Any) {
        extensionContext?.open(URL(string: "tempted://urge/2")!)
    }
    
    @IBAction func touchPhone(_ sender: Any) {
        extensionContext?.open(URL(string: "tempted://urge/3")!)
    }
    
    @IBAction func touchBread(_ sender: Any) {
        extensionContext?.open(URL(string: "tempted://urge/4")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
