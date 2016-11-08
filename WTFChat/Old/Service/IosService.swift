//
//  IosService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 27/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class IosService: Service {
    fileprivate let iosNetworkService: IosNetworkService

    fileprivate let keychain = KeychainWrapper()

    init(iosNetworkService: IosNetworkService) {
        self.iosNetworkService = iosNetworkService
    }

    func updatePushBadge(_ talks: [FriendTalk]?) {
        //can only change badge from main_queue
        DispatchQueue.main.async(execute: {
            if (talks == nil) {
                UIApplication.shared.applicationIconBadgeNumber = 0
                return
            }
            
            var badge = 0
            
            for talk in talks! {
                //ignore singleMode talk
                if (talk.isSingleMode) {
                    continue
                }
                
                badge += talk.cipheredNum
                    
                if (talk.decipherStatus != .no) {
                    badge += 1
                }
            }
                
            UIApplication.shared.applicationIconBadgeNumber = badge
        })
    }
    
    func updateDeviceToken() {
        iosNetworkService.updateDeviceToken(DEVICE_TOKEN)
    }
    
    func getKeychainUser() -> String? {
        return keychain.myObject(forKey: kSecAttrAccount) as? String
    }
    
    func getKeychainPassword() -> String? {
        return keychain.myObject(forKey: kSecValueData) as? String
    }
    
    func haveUserCredentials() -> Bool {
        let username = keychain.myObject(forKey: kSecAttrAccount) as? String
        let password = keychain.myObject(forKey: kSecValueData) as? String
        
        if (username != nil && password != nil && username != "Not set") {
            return true
        } else {
            return false
        }
    }
    
    func updateUserCredentials(_ login: String, password: String) {
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
