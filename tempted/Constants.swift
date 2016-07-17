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
}

struct TPTPadding {
    static let CellLeft: CGFloat = 12.0
    static let CellRight: CGFloat = 12.0
    static let CellBottom: CGFloat = 6.0
}

struct TPTError {
    static let PhotoNoPermissions = NSError(domain: "tempted", code: 66, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Error prepping cameras", comment: "internal error description for initializing cameras"),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Permissions not granted.", comment: "internal error reason for no permissions"),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Please grant photo permissions in your settings", comment: "User-facing recovery suggestions")
    ])
}

struct TPTString {
    static let LocationServicesDisabled = NSLocalizedString("Location services are disabled on your phone.", comment: "Error text when location services are disabled on the phone")
}