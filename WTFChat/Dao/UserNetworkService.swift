//
//  UserDao.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class UserNetworkService: NSObject {
    
    func login(login: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        self.authorize(login, password: password) { error -> Void in
            if let requestError = error {
                completion(user: nil, error: requestError)
            } else {
                self.getUserInfo() { user, error -> Void in
                    if let requestError = error {
                        completion(user: nil, error: requestError)
                    } else {
                        completion(user: user, error: nil)
                    }
                }
            }
        }
    }
    
    func logout(deviceToken: NSString?, completion:(error: NSError?) -> Void) {
        var postJSON: JSON? = nil
        
        if deviceToken != nil {
            let userData = [
                "device_token": deviceToken!
            ]
            
            postJSON = JSON(userData)
        }
        
        networkService.post(postJSON, relativeUrl: "logout") { (json, error) -> Void in
            completion(error: error)
        }
    }
    
    func register(login: String, password: String, email: String, completion:(error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password,
            "email": email
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
    
    func getNewInfo(lastUpdate: NSDate, completion:(userInfo: User?, error: NSError?) -> Void) {
        let lastUpdateData = [
            "last_update": NSDate.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "user/new_info") { (json, error) -> Void in
            if let requestError = error {
                completion(userInfo: nil, error: requestError)
            } else {
                if let userJson = json {
                    do {
                        let user = try User.parseFromJson(userJson)
                        completion(userInfo: user, error: nil)
                    } catch let error as NSError {
                        completion(userInfo: nil, error: error)
                    }
                }
            }
        }
    }
    
    func sendUsedHints(suggestionsUsed: Int, completion:(error: NSError?) -> Void) {
        let url = "user/use_suggestions/" + String(suggestionsUsed)
        networkService.post(nil, relativeUrl: url) { (json, error) -> Void in
            completion(error: error)
        }
    }
    
    func getNewFriends(searchString: String, completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        var url = "user/friends"
        
        if (searchString != "") {
            url += "/" + searchString.escapeForUrl()!
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
    
    func getTopRatings(completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        networkService.get("user/top") { (json, error) -> Void in
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
    
    func getFriendsRating(completion:(friends: [FriendInfo]?, error: NSError?) -> Void) {
        networkService.get("user/friendsRating") { (json, error) -> Void in
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
        networkService.post(nil, relativeUrl:"user/friend/" + friendLogin.escapeForUrl()!) { (json, error) -> Void in
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
    
    func updatePassword(oldPassword: String, newPassword: String, completion:(error: NSError?) -> Void) {
        let requestData = [
            "old_password": oldPassword,
            "new_password": newPassword
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/password") { (json, error) -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
            }
        }
    }
    
    func updateName(name: String, completion:(error: NSError?) -> Void) {
        let requestData = [
            "name": name
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/name") { (json, error) -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
            }
        }
    }
    
    func updateEmail(email: String, completion:(error: NSError?) -> Void) {
        let requestData = [
            "email": email
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/email") { (json, error) -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
            }
        }
    }
    
    func updatePushNew(pushNew: Bool, completion:(error: NSError?) -> Void) {
        let requestData = [
            "push_new": pushNew
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/push_new") { (json, error) -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
            }
        }
    }
    
    func updatePushDeciphered(pushDeciphered: Bool, completion:(error: NSError?) -> Void) {
        let requestData = [
            "push_deciphered": pushDeciphered
        ]
        
        let postJSON = JSON(requestData)
        
        networkService.post(postJSON, relativeUrl: "user/push_deciphered") { (json, error) -> Void in
            if let requestError = error {
                completion(error: requestError)
            } else {
                completion(error: nil)
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