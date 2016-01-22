//
//  AuthNetworkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 21/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class AuthNetworkService: NSObject {
    
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
    
    func restorePassword(login: String, completion:(error: NSError?) -> Void) {
        var userData: [String: NSString]
        
        userData = [
            "login": login,
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "restore") {json, error -> Void in
            completion(error: error)
        }
    }
    
    func changePassword(login: String, password: String, code: String, completion:(error: NSError?) -> Void) {
        let userData = [
            "login": login,
            "password": password,
            "code": code
        ]
        
        let postJSON = JSON(userData)
        
        networkService.post(postJSON, relativeUrl: "change_password") {json, error -> Void in
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
                
                networkService.updateSessionConfiguration(config)
                
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