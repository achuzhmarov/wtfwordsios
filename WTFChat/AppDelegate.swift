//
//  AppDelegate.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

var DEVICE_TOKEN: NSString?

let WAIT_FOR_USER_LOADING_IN_SECONDS = UInt32(2)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var notificationService: NotificationService!
    private var coreDataService: CoreDataService!

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        notificationService = serviceLocator.get(NotificationService)
        coreDataService = serviceLocator.get(CoreDataService)

        /*if (iosService.haveUserCredentials()) {
            authService.loginWithKeychain() { user, error -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        print(requestError)
                        self.showLoginScreen()
                    } else {
                        //do nothing - default main screen: FriendsViewController
                    }
                })
            }
        } else {
            showInitScreen()
        }*/
        
        //subscribe for pushNotifications
        //if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        /*} else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }*/
        
        sleep(WAIT_FOR_USER_LOADING_IN_SECONDS)
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
        {
            notificationService.computeInactiveNotification(notification)
        }
        
        return true
    }

    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        DEVICE_TOKEN = tokenString

        //TODO - update device token
        /*if (currentUserService.isLoggedIn()) {
            iosService.updateDeviceToken()
        }*/
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if (application.applicationState == .Inactive || application.applicationState == .Background)
        {
            //opened from a push notification when the app was closed
            notificationService.computeInactiveNotification(userInfo)
        } else {
            //was in front
            notificationService.computeActiveNotification(userInfo)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataService.saveContext()
    }
}

