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
    var avPlayerViewController: AVPlayerViewController
    
    
    override func viewDidAppear(_ animated: Bool) {
        let movieUrl:NSURL? = NSURL (string: "http://YOUR URL")
        if let url = movieUrl {
            self.avPlayer = AVPlayer(URL: url)
            self.avPlayerViewController.player = self.avPlayer
        }
        self.present(self.avPlayerViewController, animated: <#T##Bool#>) { () -> Void in
            self.avPlayerViewController.player?.play()
        }
        
    }

    var originalOrientation: Int?

    override func viewWillAppear(_ animated: Bool) {
        originalOrientation = UIDevice.current.orientation.rawValue
        let newOrientation = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(newOrientation, forKey: "orientation")
    }

   internal weak var delegate: WorkingUIViewControllerDelegate?

    @IBAction func workoutComplete(_ sender: UIButton) {
        UIDevice.current.setValue(originalOrientation!, forKey: "orientation")
        self.delegate!.endWorkout(self)
    }

}
