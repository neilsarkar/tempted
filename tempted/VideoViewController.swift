//
//  VideoViewController.swift
//  Tempted
//
//  Created by Neil Sarkar on 29/11/17.
//  Copyright © 2017 Neil Sarkar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController : UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mov") else {
            print("Couldn't find tutorial.mov")
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
}
