//
//  Constants.swift
//  tempted
//
//  Created by Neil Sarkar on 6/11/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation
import CoreGraphics

struct TPTNotification {
// MARK: Urge Lifecycle
    static let CreateUrge = "Create Urge"
    static let UrgeCreated = "Urge Created"
    static let UrgeCreateFailed = "Urge Create Failed"
    static let UrgeDeleted = "Urge Deleted"
    
// MARK: Location
    static let MapPermissionsGranted = "Map permissions granted"
    static let ErrorLocationServicesDisabled = "Location Services Disabled"
    static let ErrorNoMapPermissions = "No map permissions"
}

struct TPTInterval {
    static let Respawn = 10.0
    static let PushReaction = 1.0
    static let PhotoSwitchDelay = Int64(100 * NSEC_PER_MSEC)
}

struct TPTPadding {
    static let CellLeft: CGFloat = 12.0
    static let CellRight: CGFloat = 12.0
    static let CellBottom: CGFloat = 6.0
}

struct TPTString {
    static let LocationServicesDisabled = NSLocalizedString("Location services are disabled on your phone.", comment: "Error text when location services are disabled on the phone")
    
    // Permissions Needed View
    static let LocationPermissionsWarning = NSLocalizedString("Tempted is useless without location services.", comment: "Blocking text presented when user needs to change map permissions")
    static let LocationReason = "maps"
    static let PhotoPermissionsWarning = NSLocalizedString("Tempted is useless without photo services.", comment: "Blocking text presented when user needs to change photo permissions")
    static let PhotoReason = "photos"
}

struct TPTError {
    static let PhotoPermissionsDeclined = NSError(domain: "tempted", code: 66, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error using cameras", comment: "internal error description for initializing cameras"),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Permissions declined.", comment: "internal error reason for no permissions"),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please grant photo permissions in your settings", comment: "User-facing recovery suggestions")
    ])
    static let PhotoPermissionsNotDetermined = NSError(domain: "tempted", code: 67, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error using cameras", comment: "internal error description for initializing cameras"),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Permissions not determined.", comment: "internal error reason for no permissions"),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Present permissions dialog", comment: "internal recovery suggestions")
    ])
    
    static let MapPermissionsDeclined = NSError(domain: "tempted", code: 68, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error getting latlng", comment: "internal error description for capturing location"),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Permissions not granted.", comment: "internal error reason for no permissions"),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please grant location permissions in your settings", comment: "User-facing recovery suggestions")
    ])
    static let MapPermissionsNotDetermined = NSError(domain: "tempted", code: 69, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error getting latlng", comment: "internal error description for initializing cameras"),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Permissions not determined.", comment: "internal error reason for no permissions"),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Present permissions dialog", comment: "internal recovery suggestions")
    ])
}