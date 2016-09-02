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
import RxSwift
import RxCocoa


class ApplicationState{
    var userName = Variable<String?>(nil)
}

class WelcomeUIViewController: UIViewController, NewUserUIViewControllerDelegate {
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    var state = ApplicationState()
    var subscriptionUserName: Disposable?
    
    override func viewDidAppear(_ animated: Bool) {
        state.userName.value = FIRAuth.auth()?.currentUser?.displayName
        
        self.subscriptionUserName = state.userName.asObservable().subscribe(onNext: { myName in
            if let strName = myName {
                self.lblWelcomeMessage.text = "\(strName) welcome to classfitter. The next workout starts in 3 minutes. Click enter below to join the locker room."
            }
            else
            {
                self.lblWelcomeMessage.text = "Wecome to classfitter. The next workout starts in 3 minutes. Click enter below to join the locker room."
            }
            
        })
    }

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.subscriptionUserName?.dispose()
    }

    @IBOutlet weak var lblWelcomeMessage: UILabel!
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
                state.userName.value = nil
            }
            catch {
                print("Failed to sign out the user")
            }
        }
    }
    
    
    
    
}
