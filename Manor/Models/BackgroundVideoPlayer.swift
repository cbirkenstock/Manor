//
//  BackgroundVideoPlayer.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/11/21.
//

import Foundation
import AVFoundation
import UIKit

class BackgroundVideoPlayer {
    
    var queuePlayer: AVQueuePlayer!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    func playVideo (video: String, type: String, controller: UIViewController) {
        
        let theURL = Bundle.main.url(forResource: video, withExtension: type)
        
        avPlayer = AVPlayer(url: theURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = .resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = controller.view.layer.bounds
        controller.view.backgroundColor = .clear
        controller.view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: .zero, completionHandler: nil)
    }
}








