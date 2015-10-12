//
//  UserDao.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let userService = UserService()

class UserService {
    var currentUser: User?
    var suggestionsUsed : Int = 0
    
    func useSuggestion() {
        currentUser!.suggestions--
        suggestionsUsed++
    }
    
    func getCurrentUser() -> User {
        return currentUser!
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
                        completion(user: user, error: nil)
                    }
                }
            }
        }
    }
    
    func logout() {
        networkService.post(nil, relativeUrl: "logout") { (json, error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                //ok - do nothing
            }
        }
        
        currentUser = nil
        networkService.session = NSURLSession.sharedSession()
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
    
    func getUnreadTalks(lastUpdate: NSDate, completion:(talks: [Talk]?, error: NSError?) -> Void) {
        let lastUpdateData = [
            "last_update": NSDate.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "user/new_talks_by_time") { (json, error) -> Void in
            if let requestError = error {
                completion(talks: nil, error: requestError)
            } else {
                if let talksJson = json {
                    do {
                        let talks = try Talk.parseArrayFromJson(talksJson)
                        completion(talks: talks, error: nil)
                    } catch let error as NSError {
                        completion(talks: nil, error: error)
                    }
                } else {
                    completion(talks: nil, error: nil)
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
    
    func getAvatarImage(name: String, diameter: UInt) -> JSQMessagesAvatarImage {
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        
        let initials : String? = name[0...min(2, nameLength)].capitalizedString
        
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
    }
    
    private func authorize(login: String, password: String, completion:(error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password
        ]
        
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