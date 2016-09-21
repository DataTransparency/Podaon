//
//  WorkingUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 24/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AVKit
import AVFoundation

protocol WorkingUIViewControllerDelegate: AnyObject {
    func endWorkout(_ controller: WorkingUIViewController)
}

class WorkingUIViewController: UIViewController {
    
    var avPlayer: AVPlayer?
    var avPlayerViewController = AVPlayerViewController()
    
    override func viewDidAppear(_ animated: Bool) {
        let movieUrl:URL? = URL (string: "https://tungsten.aaplimg.com/VOD/bipbop_adv_fmp4_example/master.m3u8")
        if let url = movieUrl {
            self.avPlayer = AVPlayer(url: url)
            avPlayerViewController.player = self.avPlayer
            avPlayerViewController.showsPlaybackControls = false
            self.addChildViewController(avPlayerViewController)
            self.myView.addSubview(avPlayerViewController.view)
            self.myView.sendSubview(toBack: avPlayerViewController.view)
            avPlayerViewController.view.frame = self.myView.frame
            self.avPlayer?.play()
        }
    }


    @IBOutlet var myView: UIView!
    
    var originalOrientation: Int?

    override func viewWillAppear(_ animated: Bool) {
        originalOrientation = UIDevice.current.orientation.rawValue
        let newOrientation = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(newOrientation, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

   internal weak var delegate: WorkingUIViewControllerDelegate?

    @IBAction func workoutComplete(_ sender: UIButton) {
       completeWorkout()
    }
    
    func completeWorkout(){
        UIDevice.current.setValue(originalOrientation!, forKey: "orientation")
        self.delegate!.endWorkout(self)
    }

}
