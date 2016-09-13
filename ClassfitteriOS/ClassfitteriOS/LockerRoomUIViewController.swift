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
import FirebaseMessaging
import PromiseKit
import FirebaseDatabase
import RxSwift



class LockerRoomMessage{
    
}


class LockerRoomUIViewController: UIViewController, WorkingUIViewControllerDelegate, ResultsUIViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageList.delegate = self
        self.messageList.dataSource = self
    }
    var comments: [FIRDataSnapshot] = []
    let ref = FIRDatabase.database().reference()
    
    override func viewWillAppear(_ animated: Bool) {
        
        ref.observe(FIRDataEventType.childAdded, with: { (snapshot: FIRDataSnapshot) in
            print("got locker room");
            let message = snapshot.value! as! String
            print(message);
            self.comments.append(snapshot)
            self.messageList.reloadData()

        }) { (Error) in
                print("Error")
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as UITableViewCell
        cell.textLabel?.text = self.comments[indexPath.row].value as! String?
        return cell
    }

    @IBOutlet weak var messageList: UITableView!

    @IBOutlet weak var newMessage: UITextField!

    @IBAction func sendMessage(_ sender: AnyObject) {
        ref.child("newMessage").setValue(newMessage.text)
    }
    func beginWork()
    {
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
