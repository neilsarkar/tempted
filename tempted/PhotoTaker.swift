//
//  PhotoTaker.swift
//  tempted
//
//  Created by Neil Sarkar on 16/07/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import AVFoundation
import CoreGraphics
import UIKit

class PhotoTaker: NSObject {
    // AV resources
    let photoQueue = DispatchQueue(label: "session queue")
    var photoSession: AVCaptureSession?
    var photoOutput: AVCaptureStillImageOutput?
    var selfieInput: AVCaptureInput?
    var selfieData: Data?
    var rearInput: AVCaptureInput?
    var rearData: Data?

    // State
    var hasPhotoPermissions = false
    var isSelfie = true
    var isInitialized = false
    var initializationError: NSError?
    
    override init() {
        super.init()
        #if IOS_SIMULATOR
            self.isInitialized = true
        #else
            prepCameras({err in
                if( err != nil ) {
                    self.initializationError = err
                    return
                }
                self.isInitialized = true
            })
        #endif
    }
    
    func takePhotos(_ cb: @escaping (NSError?, _ selfieData: Data?, _ rearData: Data?) -> Void) {
        #if IOS_SIMULATOR
            return cb(nil, nil, nil)
//            return cb(nil, dummyPhoto(.purple), dummyPhoto(.orange))
        #endif
        
        if( initializationError != nil ) {
            return cb(initializationError, nil, nil)
        }
        
        if( !isInitialized ) {
            let err = NSError(domain: "tempted", code: 2, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("Cameras not initialized", comment: "internal error reason for initialization not complete"),
                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Gah, I'm still trying to find your camera! Try back soon :/", comment: "recovery message for user tapping the urge button before we're ready")
            ])
            return cb(err, nil, nil)
        }
        
        if( self.rearInput == nil || self.selfieInput == nil ) {
            // TODO: return inputs in user info
            let err = NSError(domain: "tempted", code: 2, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("One of the inputs is nil", comment: "internal error reason for nil photo inputs")
            ])
            
            return cb(err, nil, nil)
        }
        
        
        takePhoto({ err, data in
            if( err != nil) { return cb(err, nil, nil) }

            // TODO: don't store on self
            self.selfieData = data
            let err = self.switchCameras()
            if( err != nil ) {
                return cb(err, self.selfieData, nil)
            }

            self.photoQueue.asyncAfter(deadline: DispatchTime.now() + Double(TPTInterval.PhotoSwitchDelay) / Double(NSEC_PER_SEC), execute: {
                self.takePhoto({ err, data in
                    if( err != nil ) {
                        return cb(err, self.selfieData, nil)
                    }
                    
                    self.rearData = data
                    let err = self.switchCameras()
                    if( err != nil ) {
                        return cb(err, self.selfieData, nil)
                    }
                    
                    return cb(err, self.selfieData, self.rearData)
                })
            })
        })
    }

    func requestPermissions() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
            self.hasPhotoPermissions = success

            #if IOS_SIMULATOR
                return
            #else
                if( success ) {
                    self.photoQueue.resume()
                }
            #endif
        })
    }
    
    private func takePhoto(_ cb: @escaping (NSError?, _ data: Data?) -> Void) {
        if( photoOutput == nil ) {
            let err = NSError(domain: "tempted", code: 2, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("Photo output is nil", comment: "internal error reason for nil output connection")
            ])
            return cb(err, nil)
        }
        
        photoQueue.async(execute: {
            
            let output = self.photoOutput!
            let connection = output.connection(with: AVMediaType.video)
            
            if( connection == nil ) {
                let err = NSError(domain: "tempted", code: 2, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error taking photo", comment: "internal error description for taking photos"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Selfie connection is nil", comment: "internal error reason for nil output connection")
                ])
                return cb(err, nil)
            }
            
            output.captureStillImageAsynchronously(from: connection!, completionHandler: { buffer, error in
                if( error != nil ) {
                    return cb(error! as NSError, nil)
                }
                
                return cb(nil, AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!))
            })
        })
    }
    
    private func prepCameras(_ cb: @escaping (NSError?) -> Void) {
        photoSession = AVCaptureSession()
        
        switch( AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ) {
        case .authorized:
            hasPhotoPermissions = true
            break
        case .notDetermined:
            photoQueue.suspend()
        default:
            hasPhotoPermissions = false
        }
        
        photoQueue.async(execute: {
            if( !self.hasPhotoPermissions ) {
                let err = TPTError.PhotoPermissionsDeclined
                return cb(err)
            }

            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
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
                if( (device ).position == .back ) {
                    photoDevice = device
                } else if( (device ).position == .front ) {
                    selfieDevice = device
                }
            }
            
            let session = self.photoSession!
            
            session.beginConfiguration()
            
            do {
                self.selfieInput = try AVCaptureDeviceInput.init(device: selfieDevice )
            } catch let err as NSError {
                return cb(err)
            }
            
            do {
                self.rearInput = try AVCaptureDeviceInput.init(device: photoDevice )
            } catch let err as NSError {
                return cb(err)
            }
            
            if( !session.canAddInput(self.selfieInput!) ) {
                let err = NSError(domain: "tempted", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error prepping cameras", comment: "internal error description for initializing cameras"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Can't add selfie input.", comment: "internal error reason for not being able to add selfie input")
                ])

                return cb(err)
            }
            session.addInput(self.selfieInput!)
            
            let stillImageOutput = AVCaptureStillImageOutput()
            if( !session.canAddOutput(stillImageOutput) ) {
                let err = NSError(domain: "tempted", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error prepping cameras", comment: "internal error description for initializing cameras"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Can't add photo output.", comment: "internal error reason for not being able to add photo output")
                ])

                return cb(err)
            }
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            session.addOutput(stillImageOutput)
            self.photoOutput = stillImageOutput

            session.commitConfiguration()
            session.startRunning()
            if( !session.isRunning ) {
                let err = NSError(domain: "tempted", code: 1, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString("Error prepping cameras", comment: "internal error description for initializing cameras"),
                    NSLocalizedFailureReasonErrorKey: NSLocalizedString("Photo session didn't start.", comment: "internal error reason for not being able to start camera session")
                ])
                
                return cb(err)
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
            newInput = self.rearInput
        } else {
            oldInput = self.rearInput
            newInput = self.selfieInput
        }
        
        session.removeInput(oldInput!)
        if( !session.canAddInput(newInput!) ) {
            // TODO: set up real error codes
            let err = NSError(domain: "tempted", code: 1, userInfo: [
                NSLocalizedDescriptionKey: NSLocalizedString("Error switching camera inputs", comment: "internal error description for switching from front facing camera to rear facing camera"),
                NSLocalizedFailureReasonErrorKey: NSLocalizedString("Couldn't add photo input", comment: "internal error reason for not being able to add photo input")
            ])
            return err
        }
        session.addInput(newInput!)
        session.commitConfiguration()
        isSelfie = !isSelfie
        return nil
    }
    
    private func dummyPhoto(_ color: UIColor = UIColor.cyan) -> Data? {
        let bounds = UIScreen.main.bounds
        let rect = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.height))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if( img == nil ) {
            return nil
        }
        
        return UIImagePNGRepresentation(img!)
    }
}
