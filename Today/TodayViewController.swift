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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
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
