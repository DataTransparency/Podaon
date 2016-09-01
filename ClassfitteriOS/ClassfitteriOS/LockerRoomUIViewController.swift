//
//  LockerRoomUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 24/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class LockerRoomUIViewController: UIViewController, WorkingUIViewControllerDelegate, ResultsUIViewControllerDelegate {

    override func viewDidAppear(_ animated: Bool) {
        // txtNewMessage?.becomeFirstResponder()
        FIRAnalytics.logEvent(withName: kFIREventSelectContent, parameters: [
            kFIRParameterContentType: "cont" as NSObject,
            kFIRParameterItemID: "1" as NSObject
            ])
    }



    @IBOutlet weak var txtNewMessage: UITextField!

    @IBAction func beginWorkout(_ sender: UIButton) {
        let uic: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "WorkingViewController"))!
        let workingViewController: WorkingUIViewController? = uic as? WorkingUIViewController
        workingViewController?.delegate = self
        self.present(uic, animated: true, completion: nil)
    }

    func endWorkout(_ controller: WorkingUIViewController) {
        controller.dismiss(animated: true, completion: {
            let uic: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ResultsUIViewController"))!
            let resultsUIViewController: ResultsUIViewController? = uic as? ResultsUIViewController
            resultsUIViewController?.delegate = self
            self.present(uic, animated: true, completion: nil)
        })
    }

    func endResults(_ controller: ResultsUIViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
