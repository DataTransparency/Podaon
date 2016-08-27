//
//  WorkingUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 24/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit

protocol WorkingUIViewControllerDelegate: AnyObject {
    func endWorkout(controller: WorkingUIViewController)
}

class WorkingUIViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
    }

    var originalOrientation: Int?

    override func viewWillAppear(animated: Bool) {
        originalOrientation = UIDevice.currentDevice().orientation.rawValue
        let newOrientation = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(newOrientation, forKey: "orientation")
    }

   internal weak var delegate: WorkingUIViewControllerDelegate?

    @IBAction func workoutComplete(sender: UIButton) {
        UIDevice.currentDevice().setValue(originalOrientation!, forKey: "orientation")
        self.delegate!.endWorkout(self)
    }

}
