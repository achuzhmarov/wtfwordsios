import Foundation
import Localize_Swift

class DailyHintsService: Service {
    let inAppService: InAppService
    let currentUserService: CurrentUserService

    fileprivate let DAILY_WTFS_TEXT = "Daily free WTFs!\nToday you got".localized()

    init(inAppService: InAppService, currentUserService: CurrentUserService) {
        self.inAppService = inAppService
        self.currentUserService = currentUserService
    }

    func computeDailyWtfs() {
        let now = Date()
        let lastLogin = currentUserService.getLastLogin()

        if (checkDailyHints(now, lastLogin: lastLogin as Date)) {
            addDailyWtfs()
            currentUserService.clearAdWtfsLimit()
        }

        currentUserService.updateLastLogin(now)
    }

    fileprivate func checkDailyHints(_ now: Date, lastLogin: Date) -> Bool {
        if (lastLogin.getYear() < now.getYear()
                || lastLogin.getMonth() < now.getMonth()
                || lastLogin.getDay() < now.getDay()) {

            return true
        }

        return false
    }

    fileprivate func addDailyWtfs() {
        let userLvl = currentUserService.getUserLvl()
        let wtfs = getRandomDailyWtfs(userLvl)

        currentUserService.addWtfs(wtfs)

        WTFOneButtonAlert.show(DAILY_WTFS_TEXT + " " + String(wtfs), message: nil)
    }

    func getRandomDailyWtfs(_ userLvl: Int) -> Int {
        var twoBorder: Int
        var threeBorder: Int

        //calculate probability border - max 100
        twoBorder = 70 - userLvl / 2
        threeBorder = 100 - userLvl / 4

        let randomNumber = Int(arc4random_uniform(UInt32(100)))
        var wtfs = 0

        if randomNumber < twoBorder {
            wtfs = 1
        } else if randomNumber < threeBorder {
            wtfs = 4
        } else {
            wtfs = 7
        }

        let secondRandom = Int(arc4random_uniform(UInt32(3)))
        wtfs += secondRandom


        if inAppService.isPurchased(IAPProducts.HINTS_X2) {
            wtfs = wtfs * 2
        }

        return wtfs
    }
}
