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
    var playerLooper: NSObject?

    @IBOutlet weak var videoView: UIView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
        subscribe()
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "com.superserious.tempted.wasOnboarded")
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUrges), name: TPTNotification.CreateUrge, object: nil)
    }
    
    @objc private func showUrges() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "com.superserious.tempted.createdUrge")
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func playVideo() {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mov") else {
            print("Couldn't find tutorial.mov")
            return
        }

        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        let player = AVQueuePlayer(items: [playerItem])
        let playerLayer = AVPlayerLayer(player: player)

        if #available(iOS 10.0, *) {
            self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        }

        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }
}
