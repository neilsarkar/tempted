//
//  UrgeSaver.swift
//  tempted
//
//  Created by Neil Sarkar on 6/11/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift
import UIKit
import AVFoundation

class UrgeSaver: NSObject, CLLocationManagerDelegate {
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!

    var isCapturingLocation = false
    
    let photoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    let sessionRunningContext = UnsafeMutablePointer<Void>(nil)
    var photoSession: AVCaptureSession?
    var photoInput: AVCaptureInput?
    var photoOutput: AVCaptureStillImageOutput?
    
    let selfieQueue = dispatch_queue_create("selfie queue", DISPATCH_QUEUE_SERIAL)
    var selfieSession: AVCaptureSession?
    var selfieInput: AVCaptureInput?
    var selfieOutput: AVCaptureStillImageOutput?
    
    var photoData: NSData?
    var selfieData: NSData?
    
    override init() {
        super.init()
        subscribe()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        prepCameras()
        captureLocation()
    }
    
    func save() {
        dispatch_async(selfieQueue, {
            let output = self.selfieOutput!
            let connection = output.connectionWithMediaType(AVMediaTypeVideo)
            
            
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, error in
                if( error != nil ) {
                    print("Error!", error)
                    return
                }
                
                self.selfieData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
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
                        
                        self.photoData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                        
                        let urge = Urge();
                        
                        // TODO: do this in initialization
                        urge.createdAt = NSDate();
                        let uuid = NSUUID().UUIDString
                        urge.id = uuid
                        if( self.latlng != nil ) {
                            urge.lat = self.latlng.latitude
                            urge.lng = self.latlng.longitude
                        }
                        
                        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                        let documentsDirectory = paths[0]
                        
                        
                        if( self.photoData != nil ) {
                            let filename = documentsDirectory.stringByAppendingString("/\(uuid)-photo.jpg")
                            self.photoData!.writeToFile(filename, atomically: true)
                            urge.photoFile = filename
                        }
                        
                        if( self.selfieData != nil ) {
                            let filename = documentsDirectory.stringByAppendingString("/\(uuid)-selfie.jpg")
                            self.selfieData!.writeToFile(filename, atomically: true)
                            urge.selfieFile = filename
                        }
                        
                        let realm = try! Realm()
                        
                        try! realm.write {
                            realm.add(urge);
                        }
                        
                        self.selfieData = nil
                        self.photoData = nil
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.UrgeCreated, object: self)
                    })
                })
            })
        })
    }
    
    internal func handleForeground(note: NSNotification) {
        captureLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        latlng = manager.location!.coordinate
        manager.stopUpdatingLocation()
        isCapturingLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        notifyLocationStatus(status)
        if( status == .AuthorizedWhenInUse && latlng == nil ) {
            captureLocation()
        }
    }
    
    private func subscribe() {
        let noteCenter = NSNotificationCenter.defaultCenter()
        // TODO: feels like a bad separation of concerns to have to include UIKit
        noteCenter.addObserver(self, selector: #selector(handleForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
        noteCenter.addObserver(self, selector: #selector(save), name: TPTNotification.CreateUrge, object: nil)
    }
    
    private func captureLocation() {
        if( isCapturingLocation ) { return }
        
        if( !CLLocationManager.locationServicesEnabled() ) {
            return NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
        }

        let authStatus = CLLocationManager.authorizationStatus()
        if( authStatus == .AuthorizedWhenInUse) {
            isCapturingLocation = true
            locationManager.startUpdatingLocation()
        } else {
            notifyLocationStatus(authStatus)
        }
    }
    
    private func prepCameras() {
        photoSession = AVCaptureSession()
        selfieSession = AVCaptureSession()
        
        // TODO: AVMediaTypeCamera?
        switch( AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ) {
        case .Authorized:
            break
        case .NotDetermined:
            dispatch_suspend(photoQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { success in
                print("auth", success)
                dispatch_resume(self.photoQueue)
            })
        default:
            // FIXME: error states
            print("Permissions denied!")
        }
        
        dispatch_async(photoQueue, {
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            var selfieDevice = devices[0]
            var photoDevice  = devices[0]

            for device in devices {
                if( device.position == AVCaptureDevicePosition.Back ) {
                    photoDevice = device
                } else if( device.position == AVCaptureDevicePosition.Front ) {
                    selfieDevice = device
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

            do {
                self.photoInput = try AVCaptureDeviceInput.init(device: photoDevice as! AVCaptureDevice)
            } catch {
                print(error)
            }
            // FIXME: catch error
            if( self.photoInput == nil ) {
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

            session.startRunning()
            if( !session.running ) {
                print("photo session not running!")
            } else {
                print("photo session running")
            }
        })
    }
    
    private func notifyLocationStatus(status: CLAuthorizationStatus) {
        switch(status) {
        case .Denied:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorNoMapPermissions, object: self)
            break
        case .Restricted:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.ErrorLocationServicesDisabled, object: self)
            break
        case .AuthorizedWhenInUse:
            NSNotificationCenter.defaultCenter().postNotificationName(TPTNotification.MapPermissionsGranted, object: self)
            break
        default:
            return
        }
    }
}