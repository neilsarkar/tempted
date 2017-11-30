//
//  LocationPermsViewController.swift
//  Tempted
//
//  Created by Neil Sarkar on 30/11/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit
import AVKit

class CameraPermsViewController : UIViewController {
    var permissions: Permissions!
    var photoTaker: PhotoTaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        permissions = Permissions()
        photoTaker = PhotoTaker()
        subscribe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if( permissions.hasPhoto() ) {
            return loadNext()
        }
    }
    
    @IBAction func requestPerms(_ sender: Any) {
        if( permissions.hasPhoto() ) {
            return loadNext()
        }
        if( !permissions.canRequestPhoto() ) {
            return appealDecision()
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { success in
            if( success ) {
                DispatchQueue.main.async {
                    self.loadNext()
                }
                return
            }

            DispatchQueue.main.async {
                self.appealDecision()
            }
        })
    }
    
    private func subscribe() {
//        NotificationCenter.default.addObserver(self, selector: #selector(loadNext), name: TPTNotification., object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appealDecision), name: TPTNotification.ErrorNoMapPermissions, object: nil)
    }
    
    @objc private func loadNext() {
        self.performSegue(withIdentifier: "nextSegue", sender: self)
    }
    
    @objc private func appealDecision() {
        self.performSegue(withIdentifier: "permissionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if( segue.destination.isKind(of: PermissionsNeededViewController.self) ) {
            let vc = segue.destination as! PermissionsNeededViewController
            vc.reason = TPTString.PhotoReason
        }
    }
    
}
