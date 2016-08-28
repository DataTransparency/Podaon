//
//  WelcomeUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 28/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit
import Google.Analytics

class WelcomeUIViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
    }

    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Welcome")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject: AnyObject])
    }


}
