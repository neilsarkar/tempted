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
    let reuseIdentifier = "UrgeCell"
    var urges: Results<Urge>?
    var creator:UrgeSaver!

    // FIXME: not our responsibility
    let photoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    let sessionRunningContext = UnsafeMutablePointer<Void>(nil)
    var photoSession: AVCaptureSession?
    var photoInput: AVCaptureInput?
    var photoOutput: AVCaptureStillImageOutput?
    
    let selfieQueue = dispatch_queue_create("selfie queue", DISPATCH_QUEUE_SERIAL)
    var selfieSession: AVCaptureSession?
    var selfieInput: AVCaptureInput?
    var selfieOutput: AVCaptureStillImageOutput?
    
    override func viewDidLoad() {
        let realm = try! Realm()
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        subscribe()
        creator = UrgeSaver()

        // FIXME: not our responsibility
        startRecordingSession()

        dispatch_async(selfieQueue, {
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            var selfieDevice = devices[0]
            
            for otherDevice in devices {
                if( otherDevice.position == AVCaptureDevicePosition.Back ) {
                    selfieDevice = otherDevice
                }
            }
            
            let session = self.selfieSession!
            
            session.beginConfiguration()
            
            do {
                self.selfieInput = try AVCaptureDeviceInput.init(device: selfieDevice as! AVCaptureDevice)
            } catch {
                print(error)
            }
            // FIXME: catch error
            if( self.selfieInput == nil ) {
                print("Could not create video device")
            }
            
            if( session.canAddInput(self.selfieInput) ) {
                session.addInput(self.selfieInput)
            } else {
                print("Could not add video input!")
            }
            
            let stillImageOutput = AVCaptureStillImageOutput()
            if( session.canAddOutput(stillImageOutput) ) {
                stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                session.addOutput(stillImageOutput)
                self.selfieOutput = stillImageOutput
            } else {
                print("Can't add still image output!")
            }
            session.commitConfiguration()
        })
        
        dispatch_async(photoQueue, {
            // FIXME: check if success
//            if ( self.setupResult != AVCamSetupResultSuccess ) {
//                return;
//            }

            
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            var photoDevice = devices[0]
            
            for otherDevice in devices {
                if( otherDevice.position == AVCaptureDevicePosition.Front ) {
                    photoDevice = otherDevice
                }
            }
            
            do {
                self.photoInput = try AVCaptureDeviceInput.init(device: photoDevice as! AVCaptureDevice)
            } catch {
                print(error)
            }
            // FIXME: catch error
            if( self.photoInput == nil ) {
                print("Could not create video device")
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        // TODO: will this cause a mem leak?
        photoSession?.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.New, context: sessionRunningContext)
        photoSession?.startRunning()
        if( !photoSession!.running ) {
            print("session not running!")
        }
        
        selfieSession?.startRunning()
        if( !selfieSession!.running ) {
            print("selfie session not running!")
        } else {
            print("selfie session running")
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if( context == sessionRunningContext ) {
            print("session running")
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func startRecordingSession() {
        photoSession = AVCaptureSession()

        selfieSession = AVCaptureSession()
        
        // TODO: AVMediaTypeCamera?
        switch( AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ) {
        case .Authorized:
            break
        case .NotDetermined:
            dispatch_suspend(photoQueue)
            dispatch_suspend(selfieQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { success in
                print("auth", success)
                dispatch_resume(self.photoQueue)
                dispatch_resume(self.selfieQueue)
            })
        default:
            // FIXME: error states
            print("Permissions denied!")
        }
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UrgeCell

        let urge = urges![indexPath.row]
        
        cell.urge = urge
        cell.urgeId = urge.id
        return cell
    }

// MARK: Event Handling
    internal func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()

        noteCenter.addObserver(self, selector: #selector(handlePoop), name: TPTNotification.CreateUrge, object: nil)

        noteCenter.addObserver(self, selector: #selector(handleUrgeAdded), name: TPTNotification.UrgeCreated, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeDelete), name: TPTNotification.UrgeDeleted, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleUrgeCreateFailed), name: TPTNotification.UrgeCreateFailed, object: nil)
        noteCenter.addObserver(self, selector: #selector(showPermissionNeeded), name: TPTNotification.ErrorNoMapPermissions, object: nil)
        noteCenter.addObserver(self, selector: #selector(showPermissionNeeded), name: TPTNotification.ErrorLocationServicesDisabled, object: nil)
    }
    
    internal func handlePoop() {
        dispatch_async(selfieQueue, {
            let output = self.selfieOutput!
            let connection = output.connectionWithMediaType(AVMediaTypeVideo)
            
            
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, error in
                if( error != nil ) {
                    print("Error!", error)
                    return
                }
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsDirectory = paths[0]
                let filename = documentsDirectory.stringByAppendingString("/selfie.jpg")
                imageData.writeToFile(filename, atomically: true)

                let session = self.selfieSession!
                session.beginConfiguration()
                session.removeInput(self.selfieInput)
                if( session.canAddInput(self.photoInput) ) {
                    session.addInput(self.photoInput)
                } else {
                    print("cannot add photo input!")
                }
                session.commitConfiguration()
                dispatch_async(self.photoQueue, {
                    let output = self.selfieOutput!
                    let connection = output.connectionWithMediaType(AVMediaTypeVideo)
                    
                    
                    output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, error in
                        if( error != nil ) {
                            print("Error!", error)
                            return
                        }
                        
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                        
                        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                        let documentsDirectory = paths[0]
                        let filename = documentsDirectory.stringByAppendingString("/halp.jpg")
                        imageData.writeToFile(filename, atomically: true)
                    })
                })
            })
        })
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
        
        // TODO: splice urges array instead of recalculating
        urges = realm.objects(Urge).sorted("createdAt", ascending: false)
        self.collectionView?.reloadData()
    }
    
// MARK: Unwind Segue
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue) {
    }
}