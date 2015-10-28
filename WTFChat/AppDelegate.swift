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

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if (iosService.haveUserCredentials()) {
            userService.loginWithKeychain() { user, error -> Void in
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
            showLoginScreen()
        }
        
        //subscribe for pushNotifications
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        sleep(WAIT_FOR_USER_LOADING_IN_SECONDS)
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
        {
            if (userService.isLoggedIn()) {
                computeInactiveNotification(notification)
            }
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func showMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("friendsNavController")
        showWindowAnimated(viewController)
    }
    
    func showFriendScreen(author: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendsNavigationController = storyboard.instantiateViewControllerWithIdentifier("friendsNavController")
            as! UINavigationController
        
        let messagesController = storyboard.instantiateViewControllerWithIdentifier("messagesController") as! MessagesViewController

        messagesController.talk = talkService.getTalkByLogin(author)
        
        friendsNavigationController.pushViewController(messagesController, animated: false)
        showWindowAnimated(friendsNavigationController)
    }
    
    func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("loginNavController")
        showWindowAnimated(viewController)
    }
    
    private func showWindowAnimated(viewController: UIViewController) {
        UIView.transitionWithView(window!,
            duration: 0.5,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: { () -> Void in
                let oldState = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)
                self.window!.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            },
            completion: nil)
    }
    
    func logout() {
        userService.logout()
        showLoginScreen()
    }
    
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        DEVICE_TOKEN = tokenString
        
        if (userService.isLoggedIn()) {
            iosService.updateDeviceToken()
        }
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //TODO logging?
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if (application.applicationState == .Inactive || application.applicationState == .Background)
        {
            //opened from a push notification when the app was closed
            computeInactiveNotification(userInfo)
        } else {
            //was in front
            computeActiveNotification(userInfo)
        }
    }
    
    func computeActiveNotification(userInfo: [NSObject : AnyObject]) {
        talkService.getNewUnreadTalks()
        
        let currentController = getCurrentController()
        if let messageViewController = currentController as? MessagesViewController {
            messageViewController.updateMessages()
        }
        
        //show localNotification (added to ios notifications window)
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let notification = UILocalNotification()
            notification.alertBody = info["alert"] as? String
            notification.fireDate = NSDate()
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    
    func computeInactiveNotification(userInfo: [NSObject : AnyObject]) {
        if let author = userInfo["author"] as? String
        {
            showFriendScreen(author)
        }
        
        /*if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let alertMsg = info["alert"] as! String
        }*/
    }
    
    func showNewSuggestionsAlert() {
        let currentController = getCurrentController()
        
        if let _ = currentController as? DecipherViewController {
            //don't show alert if deciphering
            return
        }
        
        if (userService.getUserNewSuggestions() != 0) {
            WTFOneButtonAlert.show("Free hints!",
                message: "You have just received " + String(userService.getUserNewSuggestions()),
                firstButtonTitle: "Ok",
                viewPresenter: currentController)
            
            userService.clearUserNewSuggestions()
        }
    }
    
    private func getCurrentController() -> UIViewController? {
        if let viewControllers = self.window?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if viewController.isKindOfClass(UIViewController) {
                    return viewController as UIViewController
                }
            }
        }
        
        return nil
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

