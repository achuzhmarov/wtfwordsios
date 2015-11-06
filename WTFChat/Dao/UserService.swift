//
//  UserDao.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let userService = UserService()

let USER_UPDATE_TIMER_INTERVAL = 10.0

class UserService: NSObject {
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
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(USER_UPDATE_TIMER_INTERVAL, target: self,
                selector: "getNewInfo", userInfo: nil, repeats: true)
        })
    }
    
    func loginWithKeychain(completion: (user: User?, error: NSError?) -> Void) {
        login(iosService.getKeychainUser()!, password: iosService.getKeychainPassword()!) { (user, error) -> Void in
            completion(user: user, error: error)
        }
    }
    
    func login(login: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        self.authorize(login, password: password) { error -> Void in
            if let requestError = error {
                completion(user: nil, error: requestError)
            } else {
                self.getUserInfo() { user, error -> Void in
                    if let requestError = error {
                        completion(user: nil, error: requestError)
                    } else {
                        self.setNewUser(user!, password: password)
                        completion(user: user, error: nil)
                    }
                }
            }
        }
    }
    
    func logout() {
        var postJSON: JSON? = nil
        
        if let deviceToken = DEVICE_TOKEN {
            let userData = [
                "device_token": deviceToken
            ]
            
            postJSON = JSON(userData)
        }
        
        networkService.post(postJSON, relativeUrl: "logout") { (json, error) -> Void in
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
    
    func register(login: String, password: String, completion:(error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "user/add") {json, error -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
            }
        }
    }
    
    func getNewInfo() {
        let lastUpdateData = [
            "last_update": NSDate.parseStringJSONFromDate(currentUser!.lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "user/new_info") { (json, error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                if let userJson = json {
                    do {
                        let user = try User.parseFromJson(userJson)
                        self.currentUser!.updateInfo(user)
                        
                        if (user.newSuggestions != 0) {
                            dispatch_async(dispatch_get_main_queue(), {
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.showNewSuggestionsAlert()
                            })
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
    }
    
    func sendUsedSugegstions() {
        if suggestionsUsed > 0 {
            let url = "user/use_suggestions/" + String(suggestionsUsed)
            networkService.post(nil, relativeUrl: url) { (json, error) -> Void in
                if let requestError = error {
                    print(requestError)
                } else {
                    self.suggestionsUsed = 0
                }
            }
        }
    }
    
    func getNewFriends(searchString: String, completion:(friends: [String]?, error: NSError?) -> Void) {
        var url = "user/friends"
        
        if (searchString != "") {
            url += "/" + searchString
        }
        
        networkService.get(url) { (json, error) -> Void in
            if let requestError = error {
                completion(friends: nil, error: requestError)
            } else {
                if let friendsJson = json {
                    do {
                        let friends = try User.parseFriendsFromJson(friendsJson)
                        completion(friends: friends, error: nil)
                    } catch let error as NSError {
                        completion(friends: nil, error: error)
                    }
                } else {
                    completion(friends: nil, error: nil)
                }
            }
        }
    }
    
    func makeFriends(friendLogin: String, completion:(talk: Talk?, error: NSError?) -> Void) {
        networkService.post(nil, relativeUrl:"user/friend/" + friendLogin) { (json, error) -> Void in
            if let requestError = error {
                completion(talk: nil, error: requestError)
            } else {
                if let talkJson = json {
                    do {
                        let talk = try Talk.parseFromJson(talkJson)
                        completion(talk: talk, error: nil)
                    } catch let error as NSError {
                        completion(talk: nil, error: error)
                    }
                } else {
                    completion(talk: nil, error: nil)
                }
            }
        }
    }

    private func authorize(login: String, password: String, completion:(error: NSError?) -> Void) {
        var userData: [String: NSString]
        
        if let deviceToken = DEVICE_TOKEN {
            userData = [
                "login": login,
                "password": password,
                "device_token": deviceToken
            ]
        } else {
            userData = [
                "login": login,
                "password": password
            ]
        }
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "login") {json, error -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else if let token = json!["token"].string {
                let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                let authString = "Bearer \(token)"
                config.HTTPAdditionalHeaders = ["Authorization" : authString]
                
                networkService.session = NSURLSession(configuration: config)
                
                completion(error: nil)
            } else {
                completion(error: json!["token"].error)
            }
        }
    }
    
    private func getUserInfo(completion:(user: User?, error: NSError?) -> Void) {
        networkService.get("user") { (json, error) -> Void in
            if let requestError = error {
                completion(user: nil, error: requestError)
            } else if let userJson = json {
                do {
                    let user = try User.parseFromJson(userJson)
                    completion(user: user, error: nil)
                } catch let error as NSError {
                    completion(user: nil, error: error)
                }
            }
        }
    }
}