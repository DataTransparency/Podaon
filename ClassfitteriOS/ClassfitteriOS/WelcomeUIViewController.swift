//
//  WelcomeUIViewController.swift
//  ClassfitteriOS
//
//  Created by James Wood on 28/08/2016.
//  Copyright © 2016 James Wood. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth



class WelcomeUIViewController: UIViewController, NewUserUIViewControllerDelegate {

    override func viewDidAppear(_ animated: Bool) {
            }

    override func viewWillAppear(_ animated: Bool) {
    }

    func closeNewUser(_ controller: NewUserUIViewController) {
        controller.dismiss(animated: true, completion: { [weak self] in
            self?.goToLockerRoom()
        })
    }

    func goToLockerRoom() {
        let uic: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "LockerRoomUIViewController"))!
        let vcLockerRoom: LockerRoomUIViewController? = uic as? LockerRoomUIViewController
        self.navigationController?.pushViewController(vcLockerRoom!, animated: true)
    }

    @IBAction func clickedEnter(_ sender: AnyObject) {
        if FIRAuth.auth()?.currentUser !=  nil {
 // redirect to locker room
            goToLockerRoom()
        } else {
 // ask for Name
            let uic: UIViewController = (self.storyboard?.instantiateViewController(withIdentifier: "NewUserUIViewController"))!
            let vcNewUser: NewUserUIViewController? = uic as? NewUserUIViewController
            vcNewUser?.delegate = self
            self.present(vcNewUser!, animated: true, completion: nil)
        }
    }

    @IBAction func clickSignOut(_ sender: AnyObject) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
            }
            catch {
                print("Failed to sign out the user")
            }
        }
    }
}
