//
//  PhotoTaker.swift
//  tempted
//
//  Created by Neil Sarkar on 16/07/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import AVFoundation

class PhotoTaker: NSObject {
    var hasPhotoPermissions = false
    let photoQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    var photoSession: AVCaptureSession?
    var photoInput: AVCaptureInput?
    var selfieInput: AVCaptureInput?
    var isSelfie = true
    var photoOutput: AVCaptureStillImageOutput?
    var photoData: NSData?
    var shouldFail = 3
    var selfieData: NSData?
    
    override init() {
        super.init()
        prepCameras({err in
            if( err != nil ) {
                //              TODO: don't try to take photos if this fails
                print(err)
            }
            print("Finished prepping cameras")
        })
    }
    
    func takePhotos(cb: (NSError?, selfieData: NSData?, photoData: NSData?) -> Void) {
        if( !hasPhotoPermissions ) {
            let err = NSError(domain: "tempted", code: 2, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("No permissions", comment: "internal error reason for not having permissions")
                ])
            
            return cb(err, selfieData: nil, photoData: nil)
        }
        if( self.photoInput == nil || self.selfieInput == nil ) {
            // TODO: return inputs in user info
            let err = NSError(domain: "tempted", code: 2, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("One of the inputs is nil", comment: "internal error reason for nil photo inputs")
            ])
            
            return cb(err, selfieData: nil, photoData: nil)
        }
        
        
        dispatch_async(photoQueue, {
            let output = self.photoOutput!
            let connection = output.connectionWithMediaType(AVMediaTypeVideo)
            
            if( connection == nil ) {
                let err = NSError(domain: "tempted", code: 2, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Selfie connection is nil", comment: "internal error reason for nil output connection")
                    ])
                return cb(err, selfieData: nil, photoData: nil)
            }
            
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
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString("Photo connection was nil", comment: "internal error reason for not being able to add photo input")
                            ])
                        return cb(err, selfieData: nil, photoData: nil)
                    }
                    
                    output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { buffer, err in
                        if( err != nil ) {
                            return cb(err, selfieData: self.selfieData, photoData: nil)
                        }
                        
                        self.photoData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                        
                        let err = self.switchCameras()

//                        TODO: dealloc selfieData and photoData
//                        self.selfieData = nil
//                        self.photoData = nil
                        return cb(err, selfieData: self.selfieData, photoData: self.photoData)
                    })
                })
            })
        })
    }
    
    private func prepCameras(cb: (NSError?) -> Void) {
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
                let err = NSError(domain: "tempted", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error prepping cameras", comment: "internal error description for initializing cameras"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("No AVCapture devices.", comment: "internal error reason for no devices found")
                ])
                
                return cb(err)
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
            
            // FIXME: catch error
            do {
                self.selfieInput = try AVCaptureDeviceInput.init(device: selfieDevice as! AVCaptureDevice)
            } catch {
                print(error)
            }
            if( self.selfieInput == nil ) {
                print("Could not create video device")
                return cb(nil)
            }
            
            // FIXME: catch error
            do {
                self.photoInput = try AVCaptureDeviceInput.init(device: photoDevice as! AVCaptureDevice)
            } catch {
                print(error)
            }
            if( self.photoInput == nil ) {
                print("Could not create video device")
                return cb(nil)
            }
            
            if( session.canAddInput(self.selfieInput) ) {
                session.addInput(self.selfieInput)
            } else {
                print("Could not add video input!")
                return cb(nil)
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
                // TODO: bubble error up
                print("Photo session failed to start")
            }
            
            return cb(nil)
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
        shouldFail -= 1
        if( shouldFail == 0 || !session.canAddInput(newInput) ) {
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
}