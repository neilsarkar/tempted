//
//  UrgesViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift

class UrgesViewController : UICollectionViewController {
    let reuseIdentifier = "UrgeCell"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var searches = ["Cool", "Nice", "Great"]
    var urge:Urge?
    
    func urgeForIndexPath(indexPath: NSIndexPath) -> String {
        return searches[indexPath.row]
    }

    override func viewDidLoad() {
        let realm = try! Realm()
        urge = realm.objects(Urge).first
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urge == nil ? 0 : 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UrgeCell
//        let urge = urgeForIndexPath(indexPath)
        
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.timeLabel.text = urge!.id
        return cell
    }
}