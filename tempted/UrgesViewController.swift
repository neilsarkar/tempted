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
    var urges: Results<Urge>?
    
    func urgeForIndexPath(indexPath: NSIndexPath) -> Urge {
        return urges![indexPath.row]
    }

    override func viewDidLoad() {
        let realm = try! Realm()
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urges == nil ? 0 : urges!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UrgeCell
        let urge = urgeForIndexPath(indexPath)
        
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.timeLabel.text = urge.humanTime()
        // TODO: try catch
        // TODO: deal with no map
        let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(urge.lat)+\(urge.lng)&zoom=15&size=400x400&sensor=false&markers=color:red|\(urge.lat)+\(urge.lng)"
        let url = NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        print(url)
        
        let mapImage = UIImage(data: NSData(contentsOfURL: url)!)
        cell.mapImageView.image = mapImage
        return cell
    }
}