//
//  IosService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 27/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let iosService = IosService()

class IosService {
    let keychain = KeychainWrapper()
    
    func updatePushBadge(talks: [Talk]?) {
        //can only change badge from main_queue
        dispatch_async(dispatch_get_main_queue(), {
            if (talks == nil) {
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                return
            }
            
            var badge = 0
            
            for talk in talks! {
                //ignore singleMode talk
                if (talk.isSingleMode) {
                    continue
                }
                
                badge += talk.cipheredNum
                    
                if (talk.decipherStatus != .No) {
                    badge++
                }
            }
                
            UIApplication.sharedApplication().applicationIconBadgeNumber = badge
        })
    }
    
    func updateDeviceToken() {
        var postJSON: JSON? = nil
        
        if let deviceToken = DEVICE_TOKEN {
            let userData = [
                "device_token": deviceToken
            ]
            
            postJSON = JSON(userData)
        }
        
        networkService.post(postJSON, relativeUrl: "user/ios_token") { (json, error) -> Void in
            if let requestError = error {
                print(requestError)
            } else {
                //ok - do nothing
            }
        }
    }
    
    func getKeychainUser() -> String? {
        return keychain.myObjectForKey(kSecAttrAccount) as? String
    }
    
    func getKeychainPassword() -> String? {
        return keychain.myObjectForKey(kSecValueData) as? String
    }
    
    func haveUserCredentials() -> Bool {
        let username = keychain.myObjectForKey(kSecAttrAccount) as? String
        let password = keychain.myObjectForKey(kSecValueData) as? String
        
        if (username != nil && password != nil && username != "Not set") {
            return true
        } else {
            return false
        }
    }
    
    func updateUserCredentials(login: String, password: String) {
        self.keychain.mySetObject(login, forKey:kSecAttrAccount)
        self.keychain.mySetObject(password, forKey:kSecValueData)
        self.keychain.writeToKeychain()
    }
    
    func resetUserCredentials() {
        self.keychain.mySetObject("Not set", forKey:kSecAttrAccount)
        self.keychain.mySetObject("Not set", forKey:kSecValueData)
        self.keychain.writeToKeychain()
    }
}