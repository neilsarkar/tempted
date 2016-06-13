//
//  Constants.swift
//  tempted
//
//  Created by Neil Sarkar on 6/11/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import Foundation

struct TPTNotification {
// MARK: Urge Lifecycle
    static let CreateUrge = "Create Urge"
    static let UrgeCreated = "Urge Created"
    static let UrgeCreateFailed = "Urge Create Failed"
    static let UrgeDeleted = "Urge Deleted"

// MARK: Error States
    static let ErrorLocationServicesDisabled = "Location Services Disabled"
    static let ErrorNoMapPermissions = "No map permissions"
}

struct TPTInterval {
    static let Respawn = 10.0
}

struct TPTString {
    static let LocationServicesDisabled = NSLocalizedString("Location services are disabled on your phone.", comment: "Error text when location services are disabled on the phone")
}