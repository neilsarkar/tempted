//
//  Permissions.swift
//  tempted
//
//  Created by Neil Sarkar on 17/07/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

// TODO: manage requesting permissions from here and send events (how to hook into delegate method of location manager?)
class Permissions: NSObject {
    func hasPhoto() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
    
    func canRequestPhoto() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined
    }
    
    func hasLocation() -> Bool {
        return CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    func canRequestLocation() -> Bool {
        return CLLocationManager.authorizationStatus() == .notDetermined
    }
}
