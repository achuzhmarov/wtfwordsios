//
//  UserService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 08/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let userService = UserService()

class UserService: NSObject {
    let USER_UPDATE_TIMER_INTERVAL = 10.0
    let userNetworkService = UserNetworkService()
    
    private var currentUser: User?
    private var suggestionsUsed : Int = 0
    
    var updateTimer: NSTimer?
    
    func isLoggedIn() -> Bool {
        if currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func getUserSuggestions() -> Int {
        if (!isLoggedIn()) {
            return 0
        }
        
        return currentUser!.suggestions
    }
    
    func getUserNewSuggestions() -> Int {
        if (!isLoggedIn()) {
            return 0
        }
        
        return currentUser!.newSuggestions
    }
    
    func clearUserNewSuggestions() {
        if (!isLoggedIn()) {
            return
        }
        
        currentUser!.newSuggestions = 0
    }
    
    func getUserLogin() -> String {
        if (!isLoggedIn()) {
            return ""
        }
        
        return currentUser!.login
    }
    
    func getUserExp() -> Int {
        if (!isLoggedIn()) {
            return 0
        }
        
        return currentUser!.exp
    }
    
    func getUserLvl() -> Int {
        if (!isLoggedIn()) {
            return 0
        }
        
        return currentUser!.lvl
    }
    
    func useSuggestion() {
        if (!isLoggedIn()) {
            return
        }
        
        currentUser!.suggestions--
        suggestionsUsed++
    }
    
    func setNewUser(user: User, password: String) {
        self.currentUser = user
        talkService.setTalksByNewUser(user)
        iosService.updateUserCredentials(user.login, password: password)
        
        //timer worked only on main
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.USER_UPDATE_TIMER_INTERVAL, target: self,
                selector: "getNewInfo", userInfo: nil, repeats: true)
        })
    }
    
    func sendUsedHints() {
        if suggestionsUsed > 0 {
            userNetworkService.sendUsedHints(suggestionsUsed) { error in
                if let requestError = error {
                    print(requestError)
                } else {
                    self.suggestionsUsed = 0
                }
            }
        }
    }
    
    func getNewInfo() {
        userNetworkService.getNewInfo(currentUser!.lastUpdate) {userInfo, error in
            if let requestError = error {
                print(requestError)
            } else {
                self.currentUser!.updateInfo(userInfo!)
                        
                if (userInfo!.newSuggestions != 0) {
                    dispatch_async(dispatch_get_main_queue(), {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.showNewSuggestionsAlert()
                    })
                }
            }
        }
    }
    
    func loginWithKeychain(completion: (user: User?, error: NSError?) -> Void) {
        login(iosService.getKeychainUser()!, password: iosService.getKeychainPassword()!) { (user, error) -> Void in
            completion(user: user, error: error)
        }
    }
    
    func login(login: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        userNetworkService.login(login, password: password) {user, error in
            if let requestError = error {
                completion(user: nil, error: requestError)
            } else {
                self.setNewUser(user!, password: password)
                completion(user: user, error: nil)
            }
        }
    }
    
    func logout() {
        userNetworkService.logout(DEVICE_TOKEN) {error in
            if let requestError = error {
                print(requestError)
            } else {
                //ok - do nothing
            }
        }
        
        currentUser = nil
        talkService.clearTalks()
        networkService.session = NSURLSession.sharedSession()
        iosService.resetUserCredentials()
        
        self.updateTimer?.invalidate()
    }
    
    func getNewFriends(searchString: String, completion:(friends: [String]?, error: NSError?) -> Void) {
        userNetworkService.getNewFriends(searchString, completion: completion)
    }
    
    func makeFriends(friendLogin: String, completion:(talk: Talk?, error: NSError?) -> Void) {
        userNetworkService.makeFriends(friendLogin, completion: completion)
    }
    
    func register(login: String, password: String, completion:(error: NSError?) -> Void) {
        userNetworkService.register(login, password: password, completion: completion)
    }
}