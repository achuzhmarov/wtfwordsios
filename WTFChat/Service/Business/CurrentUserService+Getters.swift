import Foundation

extension CurrentUserService {
    func getLastUpdate() -> Date {
        return user.lastUpdate as Date
    }

    func getLastLogin() -> Date {
        return user.lastLogin as Date
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

    func getUserWtf() -> Int {
        return user.wtf
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

    func getFriendInfoByLogin(_ login: String) -> FriendInfo? {
        for friend in user.friends {
            if (friend.login == login) {
                return friend
            }
        }

        return nil
    }

    func getFriendInfoByTalk(_ talk: FriendTalk) -> FriendInfo? {
        return getFriendInfoByLogin(getFriendLogin(talk))
    }

    func getFriends() -> [FriendInfo] {
        return user.friends
    }

    func canAddFreeAdWtf() -> Bool {
        if (user.adWtfGained < DAILY_MAX_AD_WTF) {
            return true
        } else {
            return false
        }
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

    func getFriendLogin(_ talk: FriendTalk) -> String {
        for user in talk.users {
            if (user != getUserLogin()) {
                return user
            }
        }

        //should never happen
        print("getFriendLogin from not a friend?")
        return ""
    }
}
