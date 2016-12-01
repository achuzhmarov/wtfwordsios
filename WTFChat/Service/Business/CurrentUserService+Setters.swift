import Foundation

extension CurrentUserService {
    func earnSingleExp(_ earnedExp: Int) {
        user.singleExp += earnedExp
        saveUserInLocalStorage()
    }

    func updateInfo(_ newUserInfo: User) {
        user.updateInfo(newUserInfo)
        saveUserInLocalStorage()
    }

    func addFriend(_ friend: FriendInfo) {
        user.friends.append(friend)
    }

    func updateName(_ name: String) {
        user.name = name
        saveUserInLocalStorage()
    }

    func updatePushNew(_ pushNew: Bool) {
        user.pushNew = pushNew
        saveUserInLocalStorage()
    }

    func updatePushDeciphered(_ pushDeciphered: Bool) {
        user.pushDeciphered = pushDeciphered
        saveUserInLocalStorage()
    }

    func useWtf(_ wtfUsed: Int) {
        user.wtf -= wtfUsed
        saveUserInLocalStorage()
    }

    func addFreeWtf(_ wtf: Int) {
        if canAddFreeAdWtf() {
            user.wtf += wtf
            user.adWtfGained += wtf
            saveUserInLocalStorage()
        }
    }

    func addWtf(_ wtf: Int) {
        user.wtf += wtf
        saveUserInLocalStorage()
    }

    func addWtfForLvlUp() -> Int {
        let wtfForLvl = expService.getWtfForLvl(getUserLvl())
        user.wtf += wtfForLvl
        saveUserInLocalStorage()

        return wtfForLvl
    }

    func updateLastLogin(_ lastLogin: Date) {
        user.lastLogin = lastLogin
        saveUserInLocalStorage()
    }

    func clearAdWtfLimit() {
        user.adWtfGained = 0
        saveUserInLocalStorage()
    }
}
