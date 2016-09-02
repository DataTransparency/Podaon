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

protocol NewUserUIViewControllerDelegate: AnyObject {
    func closeNewUser(_ controller: NewUserUIViewController)
}

class NewUserUIViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    internal weak var delegate: NewUserUIViewControllerDelegate?
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var lblValidation: UILabel!

    @IBAction func clickedNext(_ sender: AnyObject) {
        if ((txtFirstName.text) != "") && ((txtSurname.text) != "") {
            FIRAuth.auth()?.signInAnonymously() { [weak self] (user, error) in
                if self == nil {
                    return
                }
                if let signInError = error {
                    self!.lblValidation.text = "Unable to create account"
                    print(signInError.localizedDescription)
                    return
                }
                if let changeRequest = user?.profileChangeRequest() {
                    changeRequest.displayName = self!.txtFirstName.text! + " " + self!.txtSurname.text!
                    changeRequest.commitChanges { [weak self] error2 in

                        if self == nil {
                            return
                        }
                        if error2 != nil {
                            self!.lblValidation.text = "Unable to update account"
                            print(error.debugDescription)

                            return
                        }
                        self!.delegate!.closeNewUser(self!)
                    }
                }
            }
        }
        else {
            lblValidation.text = "Please complete all the fields"
        }
    }
}
