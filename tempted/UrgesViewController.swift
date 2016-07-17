//
//  UrgesViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift

class UrgesViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let topIdentifier   = "ButtonCell"
    let urgeIdentifier = "UrgeCell"
    let urgeMapOnlyIdentifier = "UrgeCellMapOnly"
    
    var urges: Results<Urge>?
    var creator:UrgeSaver!
    
    var permissionNeeded: String?
    var isDisplayingPermissionsDialog = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        self.automaticallyAdjustsScrollViewInsets = false
        subscribe()
    }
    
//  TODO: move to containing VC
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if( creator == nil ) { creator = UrgeSaver() }
        if( !defaults.boolForKey("com.superserious.tempted.onboarded") ) {
            self.performSegueWithIdentifier("ShowOnboardingVC", sender: self)
            defaults.setBool(true, forKey: "com.superserious.tempted.onboarded")
        }
    }
    
//  TODO: move to containing VC
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
// MARK: CollectionView Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if( indexPath.section == 0 ) {
            return self.view.frame.size
        }

        let urge = urgeForIndexPath(indexPath)
        let width = self.view.frame.width - (TPTPadding.CellLeft + TPTPadding.CellRight)
        let height : CGFloat
        if( urge.photo == nil && urge.selfie == nil ) {
            height = width + 29
        } else {
            height = width
        }

        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets {
        if( section == 0 ) { return UIEdgeInsetsMake(0, 0, 0, 0) }
        return UIEdgeInsetsMake(0, 0, 0, 0)
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
            cell.showReleased()
            return cell
        }

        let urge = urgeForIndexPath(indexPath)

        // TODO: share cell.urge = urge and return cell below
        // FIXME: simulator should use stock images
        if( urge.photo == nil && urge.selfie == nil ) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(urgeMapOnlyIdentifier, forIndexPath: indexPath) as! UrgeCellMapOnly
            cell.urge = urge
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(urgeIdentifier, forIndexPath: indexPath) as! UrgeCell
            cell.urge = urge
            return cell
        }
    }
    
    func urgeForIndexPath(indexPath: NSIndexPath) -> Urge {
        return urges![indexPath.row]
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

//  TODO: move this to containing view controller
    internal func showPermissionNeeded() {
        // TODO: why is this needed, since NSThread.isMainThread() returns true
        dispatch_async(dispatch_get_main_queue()) {
            self.permissionNeeded = TPTString.LocationReason
            self.performSegueWithIdentifier("ShowPermissionsNeededVC", sender: self)
        }
    }

//  TODO: move this to containing view controller
    private func showPhotoPermissionNeeded() {
        dispatch_async(dispatch_get_main_queue()) {
            self.permissionNeeded = TPTString.PhotoReason
            self.performSegueWithIdentifier("ShowPermissionsNeededVC", sender: self)
        }
    }
//  TODO: move this to containing view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("preparing for segue", segue.identifier)
        super.prepareForSegue(segue, sender: sender)
        if( segue.destinationViewController.isKindOfClass(PermissionsNeededViewController) ) {
            let vc = segue.destinationViewController as! PermissionsNeededViewController
            vc.reason = permissionNeeded!
        }
    }
    
    internal func handleUrgeCreateFailed(note:NSNotification) {
        if( note.userInfo?["err"] != nil ) {
            let err = note.userInfo!["err"] as! NSError
            if( err.code == TPTError.PhotoNoPermissions.code ) {
                showPhotoPermissionNeeded()
                return
            }
        }
        
        let alertController = UIAlertController(title: "Sorry", message: "Something went wrong.", preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {}
    }
    
    internal func handleUrgeAdded() {
        collectionView?.reloadData()
    }
    
    internal func handleUrgeDelete(note:NSNotification) {
        if( note.userInfo == nil ) { return print("UserInfo is nil in handleUrgeDelete!") }

        let id = note.userInfo!["id"] as! String
        
        let realm = try! Realm()
        let badUrge = realm.objectForPrimaryKey(Urge.self, key: id)!
        try! realm.write {
            realm.delete(badUrge)
        }
        
        collectionView?.reloadData()
    }
    
// MARK: Unwind Segue
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
}