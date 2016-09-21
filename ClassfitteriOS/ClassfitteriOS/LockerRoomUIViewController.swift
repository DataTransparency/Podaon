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


class MessageTableCell: UITableViewCell, Disposable {
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var lblCreated: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    
    var message = Variable<LockerRoomMessage?>(nil)
    
    var binding: Disposable?
    
    public func myInit(){
        
        let todayFormatter = DateFormatter()
        todayFormatter.dateStyle = .none
        todayFormatter.timeStyle = .medium
        
        let otherDayFormatter = DateFormatter()
        otherDayFormatter.dateStyle = .medium
        otherDayFormatter.timeStyle = .medium
    
        if (binding == nil) {
            self.binding = message.asObservable().subscribe(onNext: { [weak self] myMessage in
                self?.lblCreator.text = myMessage?.creator
                self?.lblBody.text = myMessage?.text
                if let created = myMessage?.created {
                    if NSCalendar.current.isDateInToday(created) {
                        self?.lblCreated.text = todayFormatter.string(from: created)
                    }
                    else{
                        self?.lblCreated.text = otherDayFormatter.string(from: created)
                    }
                }
                else
                {
                    self?.lblCreated.text = ""
                }
            })
        }
    }
    
    func dispose() {
        self.binding?.dispose()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class MessageTableCellModel{
    
}

class LockerRoomMessage{
    var text: String?
    var creator: String?
    var created: Date?
}


let lockerRoomDatabasePath = "locker-room"

class LockerRoomUIViewController: UIViewController, WorkingUIViewControllerDelegate, ResultsUIViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var state:  ApplicationState?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageList.delegate = self
        self.messageList.dataSource = self
        
        ref.child(lockerRoomDatabasePath).observe(FIRDataEventType.childAdded, with: { (snapshot: FIRDataSnapshot) in
            if let messageDict = snapshot.value! as? NSDictionary {
                let message = LockerRoomMessage()
                message.text = messageDict.value(forKey: "text") as! String?
                message.creator = messageDict.value(forKey: "creator") as! String?
                if let timestamp = messageDict.value(forKey: "created") as! TimeInterval? {
                    message.created = Date(timeIntervalSince1970: timestamp/1000)
                }
                
                self.comments.append(message)
                self.messageList.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
                
                 self.messageList.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
        }) { (Error) in
            print("Locker Room Observe Error")
        }

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

    @IBAction func startWorkoutClicked(_ sender: AnyObject) {
        beginWork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    let cellIdentifier = "MessageTableCell"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageList.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)  as! MessageTableCell
        
        cell.myInit()
        let tableMessage = self.comments[indexPath.row]
        cell.message.value = tableMessage
        return cell
    }

    @IBOutlet weak var messageList: UITableView!

    @IBOutlet weak var newMessage: UITextField!

    @IBAction func sendMessage(_ sender: AnyObject) {
        
        if let messageText = newMessage.text, let username = state?.userName.value {
            print("Sending: \(messageText) from \(username)")
            let newData = ref.child(lockerRoomDatabasePath).childByAutoId()
            
            newData.setValue(["text": messageText, "creator": username, "created": Firebase.FIRServerValue.timestamp()])
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
