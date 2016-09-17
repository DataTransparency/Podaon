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
    var text: String?
    var creator: String?
}
let lockerRoomDatabasePath = "locker-room"

class LockerRoomUIViewController: UIViewController, WorkingUIViewControllerDelegate, ResultsUIViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var state:  ApplicationState?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageList.delegate = self
        self.messageList.dataSource = self
    }
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var comments: [LockerRoomMessage] = []
    
    let ref = FIRDatabase.database().reference()
    
    func keyboardWillShow(_ notification:NSNotification)
    {
        bottomMargin = bottomHeight.constant
        if let userInfo = notification.userInfo
        {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                bottomHeight.constant = keyboardSize.height + bottomMargin
                view.setNeedsLayout()
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var bottomMargin: CGFloat = 0
    
    
    func keyboardWillHide(_ notification:NSNotification)
    {
        bottomHeight.constant = bottomMargin
        view.setNeedsLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        ref.child(lockerRoomDatabasePath).observe(FIRDataEventType.childAdded, with: { (snapshot: FIRDataSnapshot) in
            if let messageDict = snapshot.value! as? NSDictionary {
                let message = LockerRoomMessage()
                message.text = messageDict.value(forKey: "text") as! String?
                message.creator = messageDict.value(forKey: "creator") as! String?
                self.comments.append(message)
                self.messageList.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
            }
        }) { (Error) in
                print("Locker Room Observe Error")
        }

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as UITableViewCell
        let tableMessage = self.comments[indexPath.row]
        if let creator = tableMessage.creator , let text = tableMessage.text {
            cell.textLabel?.text = "\(creator): \(text)"
        }
        
        return cell
    }

    @IBOutlet weak var messageList: UITableView!

    @IBOutlet weak var newMessage: UITextField!

    @IBAction func sendMessage(_ sender: AnyObject) {
        
        if let messageText = newMessage.text, let username = state?.userName.value {
            print("Sending: \(messageText) from \(username)")
            let newData = ref.child(lockerRoomDatabasePath).childByAutoId()
            newData.setValue(["text": messageText, "creator": username])
            newMessage.text = ""
            dismissKeyboard()
        }
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
