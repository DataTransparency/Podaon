//
//  AppDelegate.swift
//  ClassfitteriOS
//
//  Created by James Wood on 7/7/16.
//  Copyright © 2016 James Wood. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrash
import FirebaseMessaging
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FIRApp.configure()
        
        let types: UIUserNotificationType = [.sound , .alert , .badge]
        let settings = UIUserNotificationSettings(types: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        FIRMessaging.messaging().subscribe(toTopic: "/topics/locker-room")
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    
        
        return true

    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Message ID:")
        print(userInfo["gcm.message_id"])
        print("%@", userInfo)
    }

    
    func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect(completion: { error in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                
                print("Connected to FCM.")
            }
        })

    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    


}


