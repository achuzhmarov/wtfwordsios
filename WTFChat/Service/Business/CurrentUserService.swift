//
//  CurrentUserService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 19/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class CurrentUserService: Service {
    let iosService: IosService
    let expService: ExpService

    private let MAX_DAILY_FREE_HINTS_FROM_AD = 3

    private struct KEY {
        static let LOGIN = "USER_LOGIN"
        static let HINTS = "USER_HINTS"
        static let LAST_UPDATE = "USER_LAST_UPDATE"
        static let EXP = "USER_EXP"
        static let SINGLE_EXP = "SINGLE_EXP"
        static let NAME = "USER_NAME"
        static let PUSH_NEW = "USER_PUSH_NEW"
        static let PUSH_DECIPHERED = "USER_PUSH_DECIPHERED"
        static let RATING = "USER_RATING"
        static let FREE_HINTS_GAINED = "USER_FREE_HINTS_GAINED"
    }

    private var user: User!

    private let storage = NSUserDefaults.standardUserDefaults()

    init(iosService: IosService, expService: ExpService) {
        self.iosService = iosService
        self.expService = expService
    }

    override func initService() {
        if (isUserExists()) {
            updateUserFromLocalStorage()
        } else {
            createUserInLocalStorage()
        }
    }

    private func isUserExists() -> Bool {
        if storage.stringForKey(KEY.LOGIN) != nil {
            return true
        } else {
            return false
        }
    }

    private func updateUserFromLocalStorage() {
        user = User(
            login: getStringField(KEY.LOGIN),
            hints: getIntField(KEY.HINTS)
        )

        user.lastUpdate = getDateField(KEY.LAST_UPDATE)
        user.exp = getIntField(KEY.EXP)
        user.singleExp = getIntField(KEY.SINGLE_EXP)
        user.name = getStringField(KEY.NAME)
        user.pushNew = getBoolField(KEY.PUSH_NEW)
        user.pushDeciphered = getBoolField(KEY.PUSH_DECIPHERED)
        user.rating = getIntField(KEY.RATING)
        user.freeHintsGained = getIntField(KEY.FREE_HINTS_GAINED)
    }

    private func getStringField(key: String) -> String {
        return storage.stringForKey(key)!
    }

    private func getIntField(key: String) -> Int {
        return storage.integerForKey(key)
    }

    private func getDateField(key: String) -> NSDate {
        return storage.objectForKey(key) as! NSDate
    }

    private func getBoolField(key: String) -> Bool {
        return storage.boolForKey(key)
    }

    private func createUserInLocalStorage() {
        let login = NSUUID().UUIDString
        let password = NSUUID().UUIDString

        iosService.updateUserCredentials(login, password: password)

        user = User(login: login)

        saveUserInLocalStorage()
    }

    private func saveUserInLocalStorage() {
        saveField(KEY.LOGIN, value: user.login)
        saveField(KEY.HINTS, value: user.hints)
        saveField(KEY.LAST_UPDATE, value: user.lastUpdate)
        saveField(KEY.EXP, value: user.exp)
        saveField(KEY.SINGLE_EXP, value: user.singleExp)
        saveField(KEY.NAME, value: user.name)
        saveField(KEY.PUSH_NEW, value: user.pushNew)
        saveField(KEY.PUSH_DECIPHERED, value: user.pushDeciphered)
        saveField(KEY.RATING, value: user.rating)
        saveField(KEY.FREE_HINTS_GAINED, value: user.freeHintsGained)
    }

    private func saveField(key: String, value: AnyObject) {
        storage.setValue(value, forKey: key)
        storage.synchronize()
    }



    func getLastUpdate() -> NSDate {
        return user.lastUpdate
    }
    
    func getUserName() -> String {
        return user.name
    }
    
    func getUserPushNew() -> Bool {
        return user.pushNew
    }
    
    func getUserPushDeciphered() -> Bool {
        return user.pushDeciphered
    }
    
    func getUserHints() -> Int {
        return user.hints
    }
    
    func getUserNewSuggestions() -> Int {
        return user.newHints
    }
    
    func getUserLogin() -> String {
        return user.login
    }
    
    func getUserFullExp() -> Int {
        return user.getFullExp()
    }

    func getUserLvl() -> Int {
        return expService.getLvl(user.getFullExp())
    }

    func getCurrentLvlExp() -> Int {
        return expService.getCurrentLvlExp(user.getFullExp())
    }

    func getNextLvlExp() -> Int {
        return expService.getNextLvlExp(user.getFullExp())
    }
    
    func getFriendInfoByLogin(login: String) -> FriendInfo? {
        for friend in user.friends {
            if (friend.login == login) {
                return friend
            }
        }
        
        return nil
    }

    func getFriendInfoByTalk(talk: FriendTalk) -> FriendInfo? {
        return getFriendInfoByLogin(getFriendLogin(talk))
    }
    
    func getFriends() -> [FriendInfo] {
        return user.friends
    }
    
    func isContainBuyNonConsum(productId: ProductIdentifier) -> Bool {
        if let productRef = IAPProducts.getProductRef(productId) {
            return user.buyNonConsum.contains(productRef)
        }
        
        return false
    }
    
    func canAddFreeAdHint() -> Bool {
        return user.freeHintsGained < MAX_DAILY_FREE_HINTS_FROM_AD
    }
    
    func getSelfUserInfo() -> FriendInfo? {
        return FriendInfo(
            login: user.login,
            lvl: getUserLvl(),
            name: user.name,
            exp: user.getFullExp(),
            rating: user.rating
        )
    }

    func getFriendLogin(talk: FriendTalk) -> String {
        for user in talk.users {
            if (user != getUserLogin()) {
                return user
            }
        }

        //should never happen
        print("getFriendLogin from not a friend?")
        return ""
    }



    func earnSingleExp(earnedExp: Int) {
        user.singleExp += earnedExp
        saveUserInLocalStorage()
    }

    func clearUserNewSuggestions() {
        user.newHints = 0
        saveUserInLocalStorage()
    }

    func updateInfo(newUserInfo: User) {
        user.updateInfo(newUserInfo)
        saveUserInLocalStorage()
    }
    
    func addFriend(friend: FriendInfo) {
        user.friends.append(friend)
    }
    
    func updateName(name: String) {
        user.name = name
        saveUserInLocalStorage()
    }
    
    func updatePushNew(pushNew: Bool) {
        user.pushNew = pushNew
        saveUserInLocalStorage()
    }
    
    func updatePushDeciphered(pushDeciphered: Bool) {
        user.pushDeciphered = pushDeciphered
        saveUserInLocalStorage()
    }
    
    func addFreeHint() {
        if canAddFreeAdHint() {
            user.hints += 1
            user.freeHintsGained += 1
            saveUserInLocalStorage()
        }
    }
}