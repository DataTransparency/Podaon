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
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        FIRApp.configure()
        

        let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_,_ in })

        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        // For iOS 10 data message (sent via FCM)
        FIRMessaging.messaging().remoteMessageDelegate = self
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Message ID:")
        print(userInfo["gcm.message_id"])
        print("%@", userInfo)
    }

    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage){
        print("Recived remote message:")
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.prod)
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        print("Token refreshed")
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
                FIRMessaging.messaging().subscribe(toTopic: "/topics/locker-room")
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


