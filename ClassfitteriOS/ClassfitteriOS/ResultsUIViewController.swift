//
//  WorkingUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 24/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit

protocol ResultsUIViewControllerDelegate: AnyObject {
    func endResults(controller: ResultsUIViewController)
}

class ResultsUIViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
    }


    override func viewWillAppear(animated: Bool) {
    }

   internal weak var delegate: ResultsUIViewControllerDelegate?

    @IBAction func closeResults(sender: UIButton) {
        self.delegate!.endResults(self)
    }

}
