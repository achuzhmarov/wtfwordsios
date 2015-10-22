//
//  AppDelegate.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

var DEVICE_TOKEN: NSString?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        DEVICE_TOKEN = tokenString
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //TODO logging?
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Recived: \(userInfo)")
        //Parsing userinfo:
        let temp : NSDictionary = userInfo
        print(temp)
        
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let alertMsg = info["alert"] as! String
            print(alertMsg)
            
            var myViewController : UIViewController!
            
            if let viewControllers = self.window?.rootViewController?.childViewControllers {
                for viewController in viewControllers {
                    if viewController.isKindOfClass(UIViewController) {
                        myViewController = viewController as UIViewController
                        print("Found the view controller")
                        print(myViewController)
                        
                        WTFOneButtonAlert.show("Push", message: alertMsg, firstButtonTitle: "Ok", viewPresenter: myViewController)
                    }
                }
            }
            
            //var alert: UIAlertView!
            //alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
            //alert.show()
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
    }
}

