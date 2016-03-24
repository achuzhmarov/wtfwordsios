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
    
    var updateTimer: NSTimer?
    
    var freeAdHintsNotAdded = 0
    
    func setNewUser(user: User, password: String) {
        currentUserService.setNewUser(user)
        talkService.setTalksByNewUser(user)
        iosService.updateUserCredentials(user.login, password: password)
        
        //timer worked only on main
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()
            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(self.USER_UPDATE_TIMER_INTERVAL, target: self,
                selector: #selector(UserService.updateInfo), userInfo: nil, repeats: true)
        })
    }
    
    func updateInfo() {
        //send free hints gain in case of errors
        if (freeAdHintsNotAdded != 0) {
            let freeAdHintsToAdd = freeAdHintsNotAdded
            freeAdHintsNotAdded = 0
            
            for _ in 0..<freeAdHintsToAdd {
                addFreeAdHintRequest()
            }
        }
        
        //get new user info
        userNetworkService.getNewInfo(currentUserService.getLastUpdate()!) {userInfo, error in
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
        
        currentUserService.updateInfo(userInfo!)
        
        if (userInfo!.newSuggestions != 0) {
            dispatch_async(dispatch_get_main_queue(), {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.showNewSuggestionsAlert()
            })
        }
    }
    
    func logoutInner() {
        currentUserService.setNewUser(nil)
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
        currentUserService.addFriend(friend)
        userNetworkService.makeFriends(friend.login, completion: completion)
    }
    
    func updatePassword(oldPassword: String, newPassword: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePassword(oldPassword, newPassword: newPassword, completion: completion)
    }
    
    func updateName(name: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updateName(name) { error in
            if (error == nil) {
                currentUserService.updateName(name)
            }
            
            completion(error: error)
        }
    }
    
    func updateEmail(email: String, password: String, completion:(error: NSError?) -> Void) {
        userNetworkService.updateEmail(email, password: password) { error in
            if (error == nil) {
                currentUserService.updateEmail(email)
            }
            
            completion(error: error)
        }
    }
    
    func updatePushNew(pushNew: Bool, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePushNew(pushNew) { error in
            if (error == nil) {
                currentUserService.updatePushNew(pushNew)
            }
            
            completion(error: error)
        }
    }
    
    func updatePushDeciphered(pushDeciphered: Bool, completion:(error: NSError?) -> Void) {
        userNetworkService.updatePushDeciphered(pushDeciphered) { error in
            if (error == nil) {
                currentUserService.updatePushDeciphered(pushDeciphered)
            }
            
            completion(error: error)
        }
    }
    
    func addFreeAdHint() {
        currentUserService.addFreeHint()
        
        addFreeAdHintRequest()
    }
    
    private func addFreeAdHintRequest() {
        userNetworkService.addFreeAdHint { (userInfo, error) -> Void in
            if let requestError = error {
                self.freeAdHintsNotAdded += 1
                
                NSLog(requestError.localizedDescription)
            } else {
                if (userInfo != nil) {
                    userService.updateUserInfo(userInfo)
                }
            }
        }
    }
}