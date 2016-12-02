import Foundation
import Localize_Swift

class DailyHintsService: Service {
    let inAppService: InAppService
    let currentUserService: CurrentUserService

    fileprivate let DAILY_WTF_TEXT = "Free Daily WTF!\nToday you have got:".localized()

    init(inAppService: InAppService, currentUserService: CurrentUserService) {
        self.inAppService = inAppService
        self.currentUserService = currentUserService
    }

    func computeDailyWtf() {
        let now = Date()
        let lastLogin = currentUserService.getLastLogin()

        if (checkDailyHints(now, lastLogin: lastLogin as Date)) {
            addDailyWtf()
            currentUserService.clearAdWtfLimit()
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

    fileprivate func addDailyWtf() {
        let userLvl = currentUserService.getUserLvl()
        let wtf = getRandomDailyWtf(userLvl)

        currentUserService.addWtf(wtf)

        WTFOneButtonAlert.show(DAILY_WTF_TEXT + " " + String(wtf), message: nil)
    }

    func getRandomDailyWtf(_ userLvl: Int) -> Int {
        var twoBorder: Int
        var threeBorder: Int

        //calculate probability border - max 100
        twoBorder = 70 - userLvl / 2
        threeBorder = 100 - userLvl / 4

        let randomNumber = Int(arc4random_uniform(UInt32(100)))
        var wtf = 0

        if randomNumber < twoBorder {
            wtf = 1
        } else if randomNumber < threeBorder {
            wtf = 3
        } else {
            wtf = 5
        }

        let secondRandom = Int(arc4random_uniform(UInt32(2)))
        wtf += secondRandom


        if inAppService.isPurchased(IAPProducts.HINTS_X2) {
            wtf = wtf * 2
        }

        return wtf
    }
}
