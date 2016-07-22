import Foundation

class CurrentUserService: Service {
    let iosService: IosService
    let expService: ExpService

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
        static let LAST_LOGIN = "USER_LAST_LOGIN"
    }

    var user: User!

    private let storage = NSUserDefaults.standardUserDefaults()

    init(iosService: IosService, expService: ExpService) {
        self.iosService = iosService
        self.expService = expService
    }

    override func initService() {
        if (storage.isFieldExists(KEY.LOGIN)) {
            updateUserFromLocalStorage()
        } else {
            createUserInLocalStorage()
        }
    }

    private func updateUserFromLocalStorage() {
        user = User(
            login: storage.getStringField(KEY.LOGIN),
            hints: storage.getIntField(KEY.HINTS)
        )

        user.lastUpdate = storage.getDateField(KEY.LAST_UPDATE)
        user.exp = storage.getIntField(KEY.EXP)
        user.singleExp = storage.getIntField(KEY.SINGLE_EXP)
        user.name = storage.getStringField(KEY.NAME)
        user.pushNew = storage.getBoolField(KEY.PUSH_NEW)
        user.pushDeciphered = storage.getBoolField(KEY.PUSH_DECIPHERED)
        user.rating = storage.getIntField(KEY.RATING)
        user.freeHintsGained = storage.getIntField(KEY.FREE_HINTS_GAINED)
        user.lastLogin = storage.getDateField(KEY.LAST_LOGIN)
    }

    private func createUserInLocalStorage() {
        let login = NSUUID().UUIDString
        let password = NSUUID().UUIDString

        iosService.updateUserCredentials(login, password: password)

        user = User(login: login)

        saveUserInLocalStorage()
    }

    func saveUserInLocalStorage() {
        storage.saveField(KEY.LOGIN, value: user.login)
        storage.saveField(KEY.HINTS, value: user.hints)
        storage.saveField(KEY.LAST_UPDATE, value: user.lastUpdate)
        storage.saveField(KEY.EXP, value: user.exp)
        storage.saveField(KEY.SINGLE_EXP, value: user.singleExp)
        storage.saveField(KEY.NAME, value: user.name)
        storage.saveField(KEY.PUSH_NEW, value: user.pushNew)
        storage.saveField(KEY.PUSH_DECIPHERED, value: user.pushDeciphered)
        storage.saveField(KEY.RATING, value: user.rating)
        storage.saveField(KEY.FREE_HINTS_GAINED, value: user.freeHintsGained)
        storage.saveField(KEY.LAST_LOGIN, value: user.lastLogin)
    }
}