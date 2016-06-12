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
import Haneke

class UrgesViewController : UICollectionViewController, CLLocationManagerDelegate {
    let topIdentifier   = "ButtonCell"
    let reuseIdentifier = "UrgeCell"
    var urges: Results<Urge>?
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    
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
        
        captureLocation()
        
        subscribe()
        
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        noteCenter.addObserver(self, selector: #selector(handleRotation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        noteCenter.addObserver(self, selector: #selector(createUrge), name: TPTNotification.ButtonTap, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeDelete), name: TPTNotification.UrgeDeleted, object: nil)
    }
    
    internal func createUrge() {
        let urge = Urge();
        
        // TODO: do this in initialization
        urge.createdAt = NSDate();
        let uuid = NSUUID().UUIDString
        urge.id = uuid
        if( latlng != nil ) {
            urge.lat = latlng.latitude
            urge.lng = latlng.longitude
            
            // TODO: delete
            let width = Int(self.view.frame.width)
            let height = Int(self.view.frame.height / 2)
            let str = "https://maps.googleapis.com/maps/api/staticmap?center=\(urge.lat)+\(urge.lng)&zoom=15&size=\(width)x\(height)&sensor=false&markers=\(urge.lat)+\(urge.lng)"
            let url = NSURL(string: str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
            
            if let data = NSData(contentsOfURL: url) {
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsDirectory = paths[0]
                let filename = documentsDirectory.stringByAppendingString("/\(uuid)-map.png")
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
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    private func captureLocation() {
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
    
    internal func handleForeground(note: NSNotification) {
        captureLocation()
    }
    
    // re-render on rotation
    internal func handleRotation(note: NSNotification) {
        self.collectionView?.reloadData()
    }
    
    internal func handleUrgeDelete(note:NSNotification) {
        if( note.userInfo == nil ) { return print("UserInfo is nil in handleUrgeDelete!") }
        let id = note.userInfo!["id"] as! String
        
        let realm = try! Realm()
        let badUrge = realm.objectForPrimaryKey(Urge.self, key: id)!
        try! realm.write {
            realm.delete(badUrge)
        }

        // TODO: splice urges array instead of recalculating
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        self.collectionView?.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if( indexPath.section == 0 ) {
            return self.view.frame.size
        }

        let width = self.view.frame.width
        let height = self.view.frame.height / 2 + 20
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets {
        if( section == 0 ) { return UIEdgeInsetsMake(0, 0, 0, 0) }
        return UIEdgeInsetsMake(0, 0, 15, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
        return 0.0
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
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UrgeCell
        let urge = urgeForIndexPath(indexPath)
        
        cell.urge = urge
        cell.urgeId = urge.id
        cell.timeLabel.text = urge.humanTime()
        cell.mapImageView.backgroundColor = UIColor.tmpGreyd1Color()
        return cell
    }
}