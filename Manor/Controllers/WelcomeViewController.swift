//
//  ViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 5/10/21.
//

import UIKit
import AVFoundation

class WelcomeViewController: UIViewController {
    
    // background video player vars
    var queuePlayer: AVQueuePlayer!
    var backgroundVideoPlayer = BackgroundVideoPlayer()
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    //buttons
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    

    
    override func viewDidLoad() {
        //button layout setup
        logInButton.layer.cornerRadius = logInButton.frame.size.height / 3.5
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height / 3.5
        
        //start video
        backgroundVideoPlayer.playVideo(video: "BackgroundVideo", type: "mp4", controller: self)
    }
    
    @IBAction func LogInPressed(_ sender: Any) {
        //goes to login
        performSegue(withIdentifier: K.Segues.loginSegue, sender: self)
    }
    
    
    @IBAction func SignUpPressed(_ sender: Any) {
        //goes to sign up
        performSegue(withIdentifier: K.Segues.signInSegue, sender: self )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //starts the video
        navigationController?.setNavigationBarHidden(true, animated: animated)
        backgroundVideoPlayer.avPlayer.play()
        paused = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //stops video playback
        backgroundVideoPlayer.avPlayer.pause()
        paused = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hides navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

