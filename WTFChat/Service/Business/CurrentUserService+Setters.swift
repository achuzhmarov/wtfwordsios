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

    func useWtfs(_ wtfsUsed: Int) {
        user.wtfs -= wtfsUsed
        saveUserInLocalStorage()
    }

    func addFreeWtfs(_ wtfs: Int) {
        if canAddFreeAdWTFs() {
            user.wtfs += wtfs
            user.adWtfsGained += wtfs
            saveUserInLocalStorage()
        }
    }

    func addWtfs(_ wtfs: Int) {
        user.wtfs += wtfs
        saveUserInLocalStorage()
    }

    func addWtfsForLvlUp() -> Int {
        let wtfsForLvl = expService.getWtfsForLvl(getUserLvl())
        user.wtfs += wtfsForLvl
        saveUserInLocalStorage()

        return wtfsForLvl
    }

    func updateLastLogin(_ lastLogin: Date) {
        user.lastLogin = lastLogin
        saveUserInLocalStorage()
    }

    func clearAdWtfsLimit() {
        user.adWtfsGained = 0
        saveUserInLocalStorage()
    }
}
