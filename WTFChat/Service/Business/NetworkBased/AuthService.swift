//
//  AuthService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 21/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let HTTP_UNAUTHORIZED = 401
let HTTP_LOGIN_EXISTS = 490
let HTTP_EMAIL_EXISTS = 491
let HTTP_INCORRECT_PASSWORD = 492
let HTTP_RESTORE_CODE_INVALID = 493
let HTTP_INCORRECT_LOGIN_OR_EMAIL = 494

class AuthService: Service {
    private let authNetworkService: AuthNetworkService
    private let iosService: IosService
    private let userService: UserService

    init(authNetworkService: AuthNetworkService, iosService: IosService, userService: UserService) {
        self.authNetworkService = authNetworkService
        self.iosService = iosService
        self.userService = userService
    }
    
    func loginWithKeychain(completion: (user: User?, error: NSError?) -> Void) {
        login(iosService.getKeychainUser()!, password: iosService.getKeychainPassword()!) { (user, error) -> Void in
            completion(user: user, error: error)
        }
    }
    
    func login(login: String, password: String, completion: (user: User?, error: NSError?) -> Void) {
        authNetworkService.login(login, password: password) {user, error in
            if let requestError = error {
                completion(user: nil, error: requestError)
            } else {
                //self.userService.setNewUser(user!, password: password)
                completion(user: user, error: nil)
            }
        }
    }
    
    func logoutNetworkRequest(completion: (error: NSError?) -> Void) {
        authNetworkService.logout(DEVICE_TOKEN) {error in
            completion(error: error)
        }
    }
    
    func register(login: String, password: String, email: String, completion:(error: NSError?) -> Void) {
        authNetworkService.register(login, password: password, email: email, completion: completion)
    }
    
    func restorePassword(login: String, completion:(error: NSError?) -> Void) {
        authNetworkService.restorePassword(login, completion: completion)
    }
    
    func changePassword(login: String, password: String, code: String, completion:(error: NSError?) -> Void) {
        authNetworkService.changePassword(login, password: password, code: code, completion: completion)
    }
}