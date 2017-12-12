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

    var unwinding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        permissions = Permissions()
        photoTaker = PhotoTaker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if( !unwinding && permissions.hasPhoto() ) {
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
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        self.unwinding = true
        return false
    }
    
}
