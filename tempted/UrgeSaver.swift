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
    // TODO: refactor location service that deals with capturing location
    var locationManager:CLLocationManager!
    var latlng:CLLocationCoordinate2D!
    var isCapturingLocation = false
    
    // TODO: refactor service object that deals with taking both photos
    var hasPhotoPermissions = false
    let photoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    var photoSession: AVCaptureSession?
    var photoInput: AVCaptureInput?
    var selfieInput: AVCaptureInput?
    var isSelfie = true
    var photoOutput: AVCaptureStillImageOutput?
    var photoData: NSData?
    var selfieData: NSData?

    // TODO: refactor service object that deals with getting permissions for both location and photos
    
    
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
        takePhotos({err, selfieData, photoData in
            // TODO: only do UI work on the main thread -- https://github.com/realm/realm-cocoa/issues/1445
            dispatch_async(dispatch_get_main_queue(), {
                let urge = Urge();
                
                // TODO: do this in initialization
                urge.createdAt = NSDate();
                let uuid = NSUUID().UUIDString
                urge.id = uuid
                if( self.latlng != nil ) {
                    urge.lat = self.latlng.latitude
                    urge.lng = self.latlng.longitude
                }
                
                if( selfieData != nil ) {
                    urge.selfie = selfieData
                }
                
                if( photoData != nil ) {
                    urge.photo = photoData
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
    
    private func takePhotos(cb: (NSError?, selfieData: NSData?, photoData: NSData?) -> Void) {
        if( !hasPhotoPermissions || self.photoInput == nil || self.selfieInput == nil ) {
            // TODO: return special error type
            return cb(nil, selfieData: nil, photoData: nil)
        }
        
        dispatch_async(photoQueue, {
            let output = self.photoOutput!
            let connection = output.connectionWithMediaType(AVMediaTypeVideo)
            
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, error in
                if( error != nil ) {
                    return cb(error, selfieData: nil, photoData: nil)
                }
                
                // TODO: don't store on self
                self.selfieData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                let err = self.switchCameras()
                if( err != nil ) {
                    return cb(err, selfieData: self.selfieData, photoData: nil)
                }
                dispatch_async(self.photoQueue, {
                    if( self.photoOutput == nil ) {
                        let err = NSError(domain: "tempted", code: 2, userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Error using photo output", comment: "internal error description for outputting photos"),
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Photo output was nil", comment: "internal error reason for not being able to add photo input")
                        ])
                        return cb(err, selfieData: nil, photoData: nil)
                    }

                    let output = self.photoOutput!
                    let connection = output.connectionWithMediaType(AVMediaTypeVideo)
                    
                    if( connection == nil ) {
                        let err = NSError(domain: "tempted", code: 2, userInfo: [
                            NSLocalizedDescriptionKey: NSLocalizedString("Unable to establish output connection", comment: "internal error description for establishing output connection"),
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString("connection was nil", comment: "internal error reason for not being able to add photo input")
                        ])
                        return cb(err, selfieData: nil, photoData: nil)
                    }
                    
                    output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, err in
                        if( err != nil ) {
                            return cb(err, selfieData: self.selfieData, photoData: nil)
                        }
                        
                        self.photoData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                        
                        // TODO: handle this error
                        let err = self.switchCameras()
                        print("Camera switch error", err)
                        return cb(nil, selfieData: self.selfieData, photoData: self.photoData)
                    })
                })
            })
        })
    }
    
    private func switchCameras() -> NSError? {
        let session = self.photoSession!
        session.beginConfiguration()
        
        var oldInput: AVCaptureInput?
        var newInput: AVCaptureInput?

        if( isSelfie ) {
            oldInput = self.selfieInput
            newInput = self.photoInput
        } else {
            oldInput = self.photoInput
            newInput = self.selfieInput
        }
        
        session.removeInput(oldInput)
        if( !session.canAddInput(newInput) ) {
            // TODO: set up real error codes
            let err = NSError(domain: "tempted", code: 1, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error switching camera inputs", comment: "internal error description for switching from front facing camera to rear facing camera"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("Couldn't add photo input", comment: "internal error reason for not being able to add photo input")
                ])
            return err
        }
        
        session.addInput(newInput)
        session.commitConfiguration()
        isSelfie = !isSelfie
        return nil
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
        
        switch( AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) ) {
        case .Authorized:
            hasPhotoPermissions = true
            break
        case .NotDetermined:
            dispatch_suspend(photoQueue)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { success in
                self.hasPhotoPermissions = success
                if( success ) {
                    dispatch_resume(self.photoQueue)
                }
            })
        default:
            hasPhotoPermissions = false
        }

        // TODO: upsell user
        if( !hasPhotoPermissions ) { return }
        
        dispatch_async(photoQueue, {
            let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
            if( devices.count == 0 ) {
                return
            }
            
            var selfieDevice = devices[0]
            var photoDevice  = devices[0]

            for device in devices {
                if( device.position == AVCaptureDevicePosition.Back ) {
                    photoDevice = device
                } else if( device.position == AVCaptureDevicePosition.Front ) {
                    selfieDevice = device
                }
            }
            
            let session = self.photoSession!
            
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
                self.photoOutput = stillImageOutput
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