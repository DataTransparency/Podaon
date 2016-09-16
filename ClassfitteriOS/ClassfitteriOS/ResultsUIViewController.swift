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
    func endResults(_ controller: ResultsUIViewController)
}

class ResultsUIViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
    }


    override func viewWillAppear(_ animated: Bool) {
    }

   internal weak var delegate: ResultsUIViewControllerDelegate?

    @IBAction func closeResults(_ sender: UIButton) {
        self.delegate!.endResults(self)
    }

}
