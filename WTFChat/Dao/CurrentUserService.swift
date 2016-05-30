//
//  CurrentUserService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 19/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class CurrentUserService: NSObject {
    private var user: User?

    private let MAX_DAILY_FREE_HINTS_FROM_AD = 3
    
    func isLoggedIn() -> Bool {
        if user != nil {
            return true
        } else {
            return false
        }
    }
    
    func getLastUpdate() -> NSDate? {
        if (!isLoggedIn()) { return nil }
        return user!.lastUpdate
    }
    
    func getUserName() -> String {
        if (!isLoggedIn()) { return "" }
        return user!.name
    }
    
    func getUserEmail() -> String {
        if (!isLoggedIn()) { return "" }
        return user!.email
    }
    
    func getUserPushNew() -> Bool {
        if (!isLoggedIn()) { return true }
        return user!.pushNew
    }
    
    func getUserPushDeciphered() -> Bool {
        if (!isLoggedIn()) { return true }
        return user!.pushDeciphered
    }
    
    func getUserSuggestions() -> Int {
        if (!isLoggedIn()) { return 0 }
        return user!.suggestions
    }
    
    func getUserNewSuggestions() -> Int {
        if (!isLoggedIn()) { return 0 }
        return user!.newSuggestions
    }
    
    func clearUserNewSuggestions() {
        if (!isLoggedIn()) { return }
        user!.newSuggestions = 0
    }
    
    func getUserLogin() -> String {
        if (!isLoggedIn()) { return "" }
        return user!.login
    }
    
    func getUserExp() -> Int {
        if (!isLoggedIn()) { return 0 }
        return user!.exp
    }
    
    func getUserLvl() -> Int {
        if (!isLoggedIn()) { return 0 }
        return user!.lvl
    }
    
    func getFriendInfoByLogin(login: String) -> FriendInfo? {
        if (!isLoggedIn()) { return nil }
        
        for friend in user!.friends {
            if (friend.login == login) {
                return friend
            }
        }
        
        return nil
    }

    func getFriendInfoByTalk(talk: Talk) -> FriendInfo? {
        return getFriendInfoByLogin(getFriendLogin(talk))
    }
    
    func getFriends() -> [FriendInfo] {
        if (!isLoggedIn()) { return [FriendInfo]() }
        return user!.friends
    }
    
    func isContainBuyNonConsum(productId: ProductIdentifier) -> Bool {
        if (!isLoggedIn()) { return false }
        
        if let productRef = IAPProducts.getProductRef(productId) {
            return user!.buyNonConsum.contains(productRef)
        }
        
        return false
    }
    
    func canAddFreeAdHint() -> Bool {
        if (!isLoggedIn()) { return false }
        return user!.freeHintsGained < MAX_DAILY_FREE_HINTS_FROM_AD
    }
    
    func getSelfUserInfo() -> FriendInfo? {
        if (!isLoggedIn()) { return nil }
        
        return FriendInfo(
            login: user!.login,
            lvl: user!.lvl,
            name: user!.name,
            exp: user!.exp,
            rating: user!.rating
        )
    }
    
    func setNewUser(newUser: User?) {
        self.user = newUser
    }
    
    func updateInfo(newUserInfo: User) {
        if (!isLoggedIn()) { return }
        self.user!.updateInfo(newUserInfo)
    }
    
    func addFriend(friend: FriendInfo) {
        if (!isLoggedIn()) { return }
        self.user!.friends.append(friend)
    }
    
    func updateName(name: String) {
        if (!isLoggedIn()) { return }
        self.user!.name = name
    }
    
    func updateEmail(email: String) {
        if (!isLoggedIn()) { return }
        self.user!.email = email
    }
    
    func updatePushNew(pushNew: Bool) {
        if (!isLoggedIn()) { return }
        self.user!.pushNew = pushNew
    }
    
    func updatePushDeciphered(pushDeciphered: Bool) {
        if (!isLoggedIn()) { return }
        self.user!.pushDeciphered = pushDeciphered
    }
    
    func addFreeHint() {
        if (!isLoggedIn()) { return }
        
        if canAddFreeAdHint() {
            self.user!.suggestions += 1
            user!.freeHintsGained += 1
        }
    }

    func getFriendLogin(talk: Talk) -> String {
        for user in talk.users {
            if (user != getUserLogin()) {
                return user
            }
        }

        //should never happen
        //TODO - add logging?
        return ""
    }

    func getMessageText(message: Message) -> String! {
        if (getUserLogin() == message.author) {
            return message.clearText()
        } else if (message.deciphered) {
            return message.clearText()
        } else {
            return message.questionMarks()
        }
    }
}