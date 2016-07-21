import Foundation

extension CurrentUserService {
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
        return true
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
}
