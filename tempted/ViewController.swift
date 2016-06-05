//
//  ViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBAction func handleButtonTapped(sender: AnyObject) {
        let dog = Dog();
        dog.name = "Neil";
        
        let realm = try! Realm()
        
        let puppies = realm.objects(Dog)
        NSLog("%d", puppies.count)
        
        try! realm.write {
            realm.add(dog);
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

