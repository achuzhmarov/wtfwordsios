import Foundation

class CurrentUserService: Service {
    let iosService: IosService
    let expService: ExpService

    let DAILY_MAX_AD_WTF = 10

    fileprivate struct KEY {
        static let LOGIN = "USER_LOGIN"
        static let HINTS = "USER_HINTS"
        static let LAST_UPDATE = "USER_LAST_UPDATE"
        static let EXP = "USER_EXP"
        static let SINGLE_EXP = "SINGLE_EXP"
        static let NAME = "USER_NAME"
        static let PUSH_NEW = "USER_PUSH_NEW"
        static let PUSH_DECIPHERED = "USER_PUSH_DECIPHERED"
        static let RATING = "USER_RATING"
        static let AD_HINTS_GAINED = "USER_AD_HINTS_GAINED"
        static let LAST_LOGIN = "USER_LAST_LOGIN"
        static let WTF = "USER_WTF"
    }

    var user: User!

    fileprivate let storage = UserDefaults.standard

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

    fileprivate func updateUserFromLocalStorage() {
        user = User(
            login: storage.getStringField(KEY.LOGIN),
            wtf: storage.getIntField(KEY.WTF)
        )

        //if user has any hints, convert it to wtf
        if (storage.getIntField(KEY.HINTS) != 0) {
            user.wtf += storage.getIntField(KEY.HINTS) * 2
            //clear hints from storage
            storage.saveField(KEY.HINTS, value: 0 as AnyObject)
        }

        user.lastUpdate = storage.getDateField(KEY.LAST_UPDATE)
        user.exp = storage.getIntField(KEY.EXP)
        user.singleExp = storage.getIntField(KEY.SINGLE_EXP)
        user.name = storage.getStringField(KEY.NAME)
        user.pushNew = storage.getBoolField(KEY.PUSH_NEW)
        user.pushDeciphered = storage.getBoolField(KEY.PUSH_DECIPHERED)
        user.rating = storage.getIntField(KEY.RATING)
        user.adWtfGained = storage.getIntField(KEY.AD_HINTS_GAINED)
        user.lastLogin = storage.getDateField(KEY.LAST_LOGIN)
    }

    fileprivate func createUserInLocalStorage() {
        let login = UUID().uuidString
        let password = UUID().uuidString

        iosService.updateUserCredentials(login, password: password)

        user = User(login: login)

        saveUserInLocalStorage()
    }

    func saveUserInLocalStorage() {
        storage.saveField(KEY.LOGIN, value: user.login as AnyObject)
        storage.saveField(KEY.HINTS, value: user.hints as AnyObject)
        storage.saveField(KEY.LAST_UPDATE, value: user.lastUpdate as AnyObject)
        storage.saveField(KEY.EXP, value: user.exp as AnyObject)
        storage.saveField(KEY.SINGLE_EXP, value: user.singleExp as AnyObject)
        storage.saveField(KEY.NAME, value: user.name as AnyObject)
        storage.saveField(KEY.PUSH_NEW, value: user.pushNew as AnyObject)
        storage.saveField(KEY.PUSH_DECIPHERED, value: user.pushDeciphered as AnyObject)
        storage.saveField(KEY.RATING, value: user.rating as AnyObject)
        storage.saveField(KEY.AD_HINTS_GAINED, value: user.adWtfGained as AnyObject)
        storage.saveField(KEY.LAST_LOGIN, value: user.lastLogin as AnyObject)
        storage.saveField(KEY.WTF, value: user.wtf as AnyObject)
    }
}
