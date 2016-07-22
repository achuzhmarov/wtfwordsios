import Foundation

class DailyHintsService: Service {
    let inAppService: InAppService
    let currentUserService: CurrentUserService

    init(inAppService: InAppService, currentUserService: CurrentUserService) {
        self.inAppService = inAppService
        self.currentUserService = currentUserService
    }

    override func initService() {
        let now = NSDate()
        let lastLogin = currentUserService.getLastLogin()

        if (checkDailyHints(now, lastLogin: lastLogin)) {
            addDailyHints()
        }

        currentUserService.updateLastLogin(now)
    }

    private func checkDailyHints(now: NSDate, lastLogin: NSDate) -> Bool {
        print("checked")

        if (lastLogin.getYear() < now.getYear()
                || lastLogin.getMonth() < now.getMonth()
                || lastLogin.getDay() < now.getDay()) {

            return true
        }

        return false
    }

    private func addDailyHints() {
        let userLvl = currentUserService.getUserLvl()
        let hints = getRandomDailyHints(userLvl)

        currentUserService.addHints(hints)

        WTFOneButtonAlert.show("Daily free hints!",
                message: "You have just received \(String(hints))",
                firstButtonTitle: "Ok")
    }

    func getRandomDailyHints(userLvl: Int) -> Int {
        var twoBorder: Int
        var threeBorder: Int

        //calculate probability border - max 60
        if userLvl <= 30 {
            twoBorder = 40 - userLvl
            threeBorder = 50
        } else if userLvl <= 60 {
            twoBorder = 10
            threeBorder = 80 - userLvl
        } else {
            twoBorder = 10
            threeBorder = 20
        }

        let randomNumber = Int(arc4random_uniform(UInt32(60)))
        var hints: Int

        if randomNumber < twoBorder {
            hints = 1
        } else if randomNumber < threeBorder {
            hints = 2
        } else {
            hints = 3
        }

        if inAppService.isPurchased(IAPProducts.HINTS_X2) {
            hints = hints * 2
        }

        return hints
    }
}
