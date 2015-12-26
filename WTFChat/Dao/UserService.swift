//
//  UserService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 08/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let userService = UserService()

let HTTP_UNAUTHORIZED = 401
let HTTP_LOGIN_EXISTS = 490
let HTTP_EMAIL_EXISTS = 491
let HTTP_INCORRECT_PASSWORD = 492

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
    
    func getUserName() -> String {
        if (!isLoggedIn()) { return "" }
        return currentUser!.name
    }
    
    func getUserEmail() -> String {
        if (!isLoggedIn()) { return "" }
        return currentUser!.email
    }
    
    func getUserPushNew() -> Bool {
        if (!isLoggedIn()) { return true }
        return currentUser!.pushNew
    }
    
    func getUserPushDeciphered() -> Bool {
        if (!isLoggedIn()) { return true }
        return currentUser!.pushDeciphered
    }
    
    func getUserSuggestions() -> Int {
        if (!isLoggedIn()) { return 0 }
        return currentUser!.suggestions
    }
    
    func getUserNewSuggestions() -> Int {
        if (!isLoggedIn()) { return 0 }
        return currentUser!.newSuggestions
    }
    
    func clearUserNewSuggestions() {
        if (!isLoggedIn()) { return }
        currentUser!.newSuggestions = 0
    }
    
    func getUserLogin() -> String {
        if (!isLoggedIn()) { return "" }
        return currentUser!.login
    }
    
    func getUserExp() -> Int {
        if (!isLoggedIn()) { return 0 }
        return currentUser!.exp
    }
    
    func getUserLvl() -> Int {
        if (!isLoggedIn()) { return 0 }
        return currentUser!.lvl
    }
    
    func useSuggestion() {
        if (!isLoggedIn()) { return }
        
        currentUser!.suggestions--
        suggestionsUsed++
    }
    
    func getFriendInfoByLogin(login: String) -> FriendInfo? {
        if (!isLoggedIn()) { return nil }
        
        for friend in currentUser!.friends {
            if (friend.login == login) {
                return friend
            }
        }
        
        return nil
    }
    
    func getFriends() -> [FriendInfo] {
        if (!isLoggedIn()) { return [FriendInfo]() }
        return currentUser!.friends
    }
    
    func isContainBuyNonConsum(productId: ProductIdentifier) -> Bool {
        if (!isLoggedIn()) { return false }
        
        if let productRef = IAPProducts.getProductRef(productId) {
            return currentUser!.buyNonConsum.contains(productRef)
        }
        
        return false
    }
    
    func getSelfUserInfo() -> FriendInfo? {
        if (!isLoggedIn()) { return nil }
        
        return FriendInfo(
            login: currentUser!.login,
            lvl: currentUser!.lvl,
            name: currentUser!.name,
            exp: currentUser!.exp,
            rating: currentUser!.rating
        )
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
                self.updateUserInfo(userInfo)
            }
        }
    }
    
    func updateUserInfo(userInfo: User?) {
        if (userInfo == nil) {
            return
        }
        
        self.currentUser!.updateInfo(userInfo!)
        
        if (userInfo!.newSuggestions != 0) {
            dispatch_async(dispatch_get_main_queue(), {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showNewSuggestionsAlert()
            })
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
        networkService.clearSession()
        iosService.resetUserCredentials()
        
        self.updateTimer?.invalidate()
    }
    
    func getNewFriends(searchString: String, completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        userNetworkService.getNewFriends(searchString, completion: completion)
    }
    
    func getTopRatings(completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        userNetworkService.getTopRatings(completion)
    }
    
    func getFriendsRating(completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        userNetworkService.getFriendsRating(completion)
    }
    
    func makeFriends(friend: FriendInfo, completion:(talk: Talk?, error: NSError?) -> Void) {
        self.currentUser!.friends.append(friend)
        userNetworkService.makeFriends(friend.login, completion: completion)
    }
    
    func register(login: String, password: String, email: String, completion:(error: NSError?) -> Void) {
        userNetworkService.register(login, password: password, email: email, completion: completion)
    }
    
    func updatePassword(oldPassword: String, newPassword: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePassword(oldPassword, newPassword: newPassword, completion: completion)
    }
    
    func updateName(name: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updateName(name) { error in
            if (error == nil) {
                self.currentUser!.name = name
            }
            
            completion(error: error)
        }
    }
    
    func updateEmail(email: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updateEmail(email) { error in
            if (error == nil) {
                self.currentUser!.email = email
            }
            
            completion(error: error)
        }
    }
    
    func updatePushNew(pushNew: Bool, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePushNew(pushNew) { error in
            if (error == nil) {
                self.currentUser!.pushNew = pushNew
            }
            
            completion(error: error)
        }
    }
    
    func updatePushDeciphered(pushDeciphered: Bool, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePushDeciphered(pushDeciphered) { error in
            if (error == nil) {
                self.currentUser!.pushDeciphered = pushDeciphered
            }
            
            completion(error: error)
        }
    }
    
    func addFreeAdHint() {
        userNetworkService.addFreeAdHint { (userInfo, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                if (userInfo != nil) {
                    userService.updateUserInfo(userInfo)
                }
            }
        }
    }
    
    let MAX_DAILY_FREE_HINTS_FROM_AD = 3
    
    func canAddFreeAdHint() -> Bool {
        if (!isLoggedIn()) { return false }
        return currentUser!.freeHintsGained < MAX_DAILY_FREE_HINTS_FROM_AD
    }
}