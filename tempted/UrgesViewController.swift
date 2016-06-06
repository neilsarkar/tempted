//
//  UrgesViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSwift
import CoreLocation

class UrgesViewController : UICollectionViewController, CLLocationManagerDelegate {
    let topIdentifier   = "ButtonCell"
    let reuseIdentifier = "UrgeCell"
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var urges: Results<Urge>?
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    
    @IBAction func handleButtonTapped(sender: AnyObject) {
        let image = UIImage(named: "DeadMosquitto")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let button = sender as! UIButton
        button.setImage(image, forState: UIControlState.Normal)
        
        let urge = Urge();
        
        // TODO: do this in initialization
        urge.createdAt = NSDate();
        if( latlng != nil ) {
            urge.lat = latlng.latitude
            urge.lng = latlng.longitude
            
            let width = Int(self.view.frame.width)
            let height = Int(self.view.frame.height / 2)
            let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(urge.lat)+\(urge.lng)&zoom=15&size=\(width)x\(height)&sensor=false&markers=\(urge.lat)+\(urge.lng)"
            let url = NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
            
            if let data = NSData(contentsOfURL: url) {
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsDirectory = paths[0]
                let filename = documentsDirectory.stringByAppendingString("/nope.png")
                data.writeToFile(filename, atomically: true)
                urge.mapFile = filename
            }
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(urge);
        }

        let indexPath = NSIndexPath(forItem: self.urges!.count - 1, inSection: 1)
        self.collectionView?.insertItemsAtIndexPaths([indexPath])
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
    }

    func urgeForIndexPath(indexPath: NSIndexPath) -> Urge {
        return urges![indexPath.row]
    }

    override func viewDidLoad() {
        let realm = try! Realm()
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not enabled")
        }        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if( indexPath.section == 0 ) {
            return self.view.frame.size
        }

        if( indexPath.section == 1 && collectionView.numberOfItemsInSection(1) == 1 ) {
            return self.view.frame.size
        }
        // TODO: calculate this from real shit
        // TODO: try catch
        // TODO: deal with no internet
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
        cell.mapImageView.image = UIImage(contentsOfFile: urge.mapFile)
        
        return cell
    }
}