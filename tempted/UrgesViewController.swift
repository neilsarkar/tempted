//
//  UrgesViewController.swift
//  tempted
//
//  Created by Neil Sarkar on 6/5/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class UrgesViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let urgeIdentifier = "UrgeCell"
    let previewIdentifier = "PreviewCell"
    
    var urges: Results<Urge>?
    var creator:UrgeSaver!
    
    var permissionNeeded: String?
    var isDisplayingPermissionsDialog = false
    var isSaving = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try! Realm()
        urges = realm.objects(Urge.self).filter("selfie != nil").sorted(byKeyPath: "createdAt", ascending: false)
        self.automaticallyAdjustsScrollViewInsets = false
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = UserDefaults.standard
        
        if( creator == nil ) { creator = UrgeSaver() }
        if( !defaults.bool(forKey: "com.superserious.tempted.onboarded") ) {
            self.performSegue(withIdentifier: "ShowOnboardingVC", sender: self)
            defaults.set(true, forKey: "com.superserious.tempted.onboarded")
        }
    }
    
// MARK: CollectionView Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width - (TPTPadding.CellLeft + TPTPadding.CellRight)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: NSInteger) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
// MARK: Section and Cell Count
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = urges == nil ? 0 : urges!.count
        if( isSaving ) { count += 1 }
        return count
    }
    
// MARK: Cell Initialization

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if( isSaving && indexPath.row == 0 ) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewIdentifier, for: indexPath)
            return cell
        }
        let urge = urgeForIndexPath(indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: urgeIdentifier, for: indexPath) as! UrgeCell
        cell.urge = urge
        return cell
    }
    
    func urgeForIndexPath(_ indexPath: IndexPath) -> Urge {
        return urges![(indexPath as NSIndexPath).row]
    }

// MARK: Event Handling
    internal func subscribe() {
        let noteCenter = NotificationCenter.default

        noteCenter.addObserver(self, selector: #selector(handleUrgeAdded), name: TPTNotification.UrgeCreated, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeDelete), name: TPTNotification.UrgeDeleted, object: nil)
        noteCenter.addObserver(self, selector: #selector(save), name: TPTNotification.CreateUrge, object: nil)
        noteCenter.addObserver(self, selector: #selector(showMapPermissionNeeded), name: TPTNotification.ErrorNoMapPermissions, object: nil)
    }

//  TODO: move this to containing view controller
    @objc internal func save(_ notification: NSNotification) {
        let data = notification.userInfo ?? [AnyHashable: Any]()

        isSaving = true
        collectionView?.reloadData()

        creator.save(data, { err in
            if( err == nil ) { return }

            self.isSaving = false
            self.collectionView?.reloadData()

            NotificationCenter.default.post(name: TPTNotification.UrgeCreateFailed, object: self)
            switch(err!.code) {
            case TPTError.MapPermissionsDeclined.code:
                self.showMapPermissionNeeded()
                break
            case TPTError.PhotoPermissionsDeclined.code:
                self.showPhotoPermissionNeeded()
                break
            case TPTError.PhotoPermissionsNotDetermined.code:
                let alertController = UIAlertController(title: "Let me take a photo", message: "I need this.", preferredStyle: .alert)
                
//              TODO: make this an NSLocalized string
                let cancelAction = UIAlertAction(title: "Nope", style: .default, handler: nil)
                let okAction = UIAlertAction(title: "Ugh, fine", style: .default, handler: { action in
                    self.creator.requestPhotoPermissions()
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                if #available(iOS 9, *) {
                    alertController.preferredAction = okAction
                }
                self.present(alertController, animated: true) {}
                break
            case TPTError.MapPermissionsNotDetermined.code:
                let alertController = UIAlertController(title: "What about maps?", message: "Can we do maps too?", preferredStyle: .alert)
//              TODO: make this an NSLocalized string
                let cancelAction = UIAlertAction(title: "Oh hell no", style: .default, handler: nil)
                let okAction = UIAlertAction(title: "This better be worth it", style: .cancel, handler: { action in
                    self.creator.requestMapPermissions()
                })
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                if #available(iOS 9, *) {
                    alertController.preferredAction = okAction
                }
                self.present(alertController, animated: true) {}
                break
            default:
                let alertController = UIAlertController(title: "Sorry", message: "Something went wrong.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true) {}
                
                print(err!)
                Crashlytics.sharedInstance().recordError(err!)
            }
            
        })
    }
    
//  TODO: move this to containing view controller
    @objc internal func showMapPermissionNeeded() {
        // TODO: why is this needed, since NSThread.isMainThread() returns true
        DispatchQueue.main.async {
            self.permissionNeeded = TPTString.LocationReason
            self.performSegue(withIdentifier: "ShowPermissionsNeededVC", sender: self)
        }
    }

//  TODO: move this to containing view controller
    private func showPhotoPermissionNeeded() {
        DispatchQueue.main.async {
            self.permissionNeeded = TPTString.PhotoReason
            self.performSegue(withIdentifier: "ShowPermissionsNeededVC", sender: self)
        }
    }
//  TODO: move this to containing view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if( segue.destination.isKind(of: PermissionsNeededViewController.self) ) {
            let vc = segue.destination as! PermissionsNeededViewController
            vc.reason = permissionNeeded!
        }
    }
    
    @objc internal func handleUrgeAdded() {
        isSaving = false
        collectionView?.reloadData()
    }
    
    @objc internal func handleUrgeDelete(_ note:Foundation.Notification) {
        if( (note as NSNotification).userInfo == nil ) {
            print("UserInfo is nil in handleUrgeDelete!")
            
            Crashlytics.sharedInstance().recordError(NSError(domain: "tempted", code: 69, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("UserInfo is nil in handleUrgeDelete!", comment: "whatever")
            ]))
            return
        }

        let id = (note as NSNotification).userInfo!["id"] as! String
        
        let realm = try! Realm()
        let badUrge = realm.object(ofType: Urge.self, forPrimaryKey: id)
        try! realm.write {
            realm.delete(badUrge!)
        }
        
        collectionView?.reloadData()
    }
    
// MARK: Unwind Segue
    
    @IBAction func unwindToHome(_ sender: UIStoryboardSegue) {
    }
}
