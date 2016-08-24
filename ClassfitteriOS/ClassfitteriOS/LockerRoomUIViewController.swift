//
//  LockerRoomUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 24/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit



class LockerRoomUIViewController: UIViewController, WorkingUIViewControllerDelegate, ResultsUIViewControllerDelegate {

    override func viewDidAppear(animated: Bool) {
        txtNewMessage?.becomeFirstResponder()
    }



    @IBOutlet weak var txtNewMessage: UITextField!

    @IBAction func beginWorkout(sender: UIButton) {

        let workingViewController: WorkingUIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WorkingViewController") as! WorkingUIViewController
        workingViewController.delegate = self
        self.presentViewController(workingViewController as UIViewController, animated: true, completion: nil)
    }

    func endWorkout(controller: WorkingUIViewController) {

        controller.dismissViewControllerAnimated(true, completion: {

            let resultsUIViewController: ResultsUIViewController
            resultsUIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ResultsUIViewController") as! ResultsUIViewController
            resultsUIViewController.delegate = self
             self.presentViewController(resultsUIViewController as UIViewController, animated: true, completion: nil)

        })

    }


    func endResults(controller: ResultsUIViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
