//
//  AppDelegate.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit
import CoreData

var DEVICE_TOKEN: NSString?

let WAIT_FOR_USER_LOADING_IN_SECONDS = UInt32(2)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        inAppService.getProductList()
        
        adColonyService.initService()
        
        if (iosService.haveUserCredentials()) {
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
            if (currentUserService.isLoggedIn()) {
                computeInactiveNotification(notification)
            }
        }
        
        return true
    }
    
    func showMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("mainTabController")
        showWindowAnimated(viewController)
    }
    
    func showFriendScreen(author: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainTabController = storyboard.instantiateViewControllerWithIdentifier("mainTabController")
            as! UITabBarController
        
        let friendsNavigationController = mainTabController.viewControllers![0] as! UINavigationController
        
        let messagesController = storyboard.instantiateViewControllerWithIdentifier("messagesController") as! MessagesViewController

        messagesController.talk = talkService.getTalkByLogin(author)
        
        showWindowAnimated(mainTabController)
        friendsNavigationController.pushViewController(messagesController, animated: false)
    }
    
    func showLoginScreen() {
        talkService.clearTalks()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let passAndPlayNavController = storyboard.instantiateViewControllerWithIdentifier("loginNavController") as! UINavigationController
        
        let passAndPlayController = passAndPlayNavController.viewControllers[0] as! MessagesViewController
        passAndPlayController.talk = talkService.getSingleModeTalk()
        
        showWindowAnimated(passAndPlayNavController)
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
        userService.logoutInner()
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
        
        if (currentUserService.isLoggedIn()) {
            iosService.updateDeviceToken()
        }
    }
    
    //Called if unable to register for APNS.
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //TODO logging?
        //print(error)
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
            messageService.updateMessages(messageViewController.talk.id)
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
    }
    
    func showNewSuggestionsAlert() {
        let currentController = getCurrentController()
        
        if let _ = currentController as? DecipherViewController {
            //don't show alert if deciphering
            return
        }
        
        if (currentUserService.getUserNewSuggestions() != 0) {
            WTFOneButtonAlert.show("Daily free hints!",
                message: "You have just received \(String(currentUserService.getUserNewSuggestions()))",
                firstButtonTitle: "Ok",
                viewPresenter: currentController)
            
            currentUserService.clearUserNewSuggestions()
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    static let projectName = "WTFChat"
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(projectName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(projectName).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                    NSInferMappingModelAutomaticallyOption: true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: migrationOptions)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

