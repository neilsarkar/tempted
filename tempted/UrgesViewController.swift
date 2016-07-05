//
//  UrgesViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift

// FIXME: not our responsibility
import AVFoundation

class UrgesViewController : UICollectionViewController {
    let topIdentifier   = "ButtonCell"
    let urgeIdentifier = "UrgeCell"
    let urgeMapOnlyIdentifier = "UrgeCellMapOnly"
    
    var urges: Results<Urge>?
    var creator:UrgeSaver!

    override func viewDidLoad() {
        let realm = try! Realm()
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        subscribe()
        creator = UrgeSaver()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
// MARK: CollectionView Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if( indexPath.section == 0 ) {
            return self.view.frame.size
        }

        let width = self.view.frame.width - 40
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets {
        if( section == 0 ) { return UIEdgeInsetsMake(0, 0, 0, 0) }
        return UIEdgeInsetsMake(0, 0, 15, 0)
    }
    
// MARK: Section and Cell Count
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( section == 0 ) { return 1; }
        return urges == nil ? 0 : urges!.count
    }

// MARK: Cell Initialization

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if( indexPath.section == 0 ) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(topIdentifier, forIndexPath: indexPath) as! ButtonCell
            return cell
        }

        let urge = urges![indexPath.row]

        // TODO: share cell.urge = urge and return cell below
        if( urge.photoFile == "" && urge.selfieFile == "" ) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(urgeMapOnlyIdentifier, forIndexPath: indexPath) as! UrgeCellMapOnly
            cell.urge = urge
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(urgeIdentifier, forIndexPath: indexPath) as! UrgeCell
            cell.urge = urge
            return cell
        }
    }

// MARK: Event Handling
    internal func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()

        noteCenter.addObserver(self, selector: #selector(handleUrgeAdded), name: TPTNotification.UrgeCreated, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeDelete), name: TPTNotification.UrgeDeleted, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeCreateFailed), name: TPTNotification.UrgeCreateFailed, object: nil)
        noteCenter.addObserver(self, selector: #selector(showPermissionNeeded), name: TPTNotification.ErrorNoMapPermissions, object: nil)
        noteCenter.addObserver(self, selector: #selector(showPermissionNeeded), name: TPTNotification.ErrorLocationServicesDisabled, object: nil)
    }
    
    internal func showPermissionNeeded() {
        // TODO: why is this needed, since NSThread.isMainThread() returns true
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("ShowPermissionsNeededVC", sender: self)
        }
    }

    internal func handleUrgeCreateFailed() {
        let alertController = UIAlertController(title: "Sorry", message: "Something went wrong.", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {}
    }
    
    internal func handleUrgeAdded() {
        let indexPath = NSIndexPath(forItem: self.urges!.count - 1, inSection: 1)
        self.collectionView?.insertItemsAtIndexPaths([indexPath])
    }
    
    internal func handleUrgeDelete(note:NSNotification) {
        if( note.userInfo == nil ) { return print("UserInfo is nil in handleUrgeDelete!") }

        let id = note.userInfo!["id"] as! String
        
        let realm = try! Realm()
        let badUrge = realm.objectForPrimaryKey(Urge.self, key: id)!
        try! realm.write {
            realm.delete(badUrge)
        }
        
        self.collectionView?.reloadData()
    }
    
// MARK: Unwind Segue
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
}