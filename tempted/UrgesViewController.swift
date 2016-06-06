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
    let topIdentifier   = "ButtonCell"
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if( indexPath.section == 0 ) {
            return self.view.frame.size
        }
        // TODO: calculate this from real shit
        let width = self.view.frame.width
        let height = self.view.frame.height / 2 + 20
        return CGSize(width: width, height: height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( section == 0 ) { return 1; }
        return urges == nil ? 0 : urges!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if( indexPath.section == 0 ) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(topIdentifier, forIndexPath: indexPath) as! ButtonCell

            let image = UIImage(named: "LiveMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            cell.button.setTitle("", forState: UIControlState.Normal)
            cell.button.setImage(image, forState: UIControlState.Normal)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UrgeCell
        let urge = urgeForIndexPath(indexPath)
        
        cell.timeLabel.text = urge.humanTime()

        // TODO: try catch
        // TODO: deal with no internet
        let width = Int(self.view.frame.width)
        let height = Int(self.view.frame.height / 2)
        let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(urge.lat)+\(urge.lng)&zoom=15&size=\(width)x\(height)&sensor=false&markers=\(urge.lat)+\(urge.lng)"
        let url = NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        print(url)

        if let data = NSData(contentsOfURL: url) {
            let mapImage = UIImage(data: data)
            cell.mapImageView.image = mapImage
        }
        
        return cell
    }
}