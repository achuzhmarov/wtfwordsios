import Foundation
import Localize_Swift

enum TutorialStage: Int {
    case never = 0, decipherGuess, decipherCloseTry, decipherCloseTryHint, decipherHint, decipherRest, finished, skipped
}

enum AppRateStatus: Int {
    case never = 0, enjoyed, rated, notEnjoyed, feedback
}

class GuiDataService: Service {
    fileprivate struct KEY {
        static let LAST_SELECTED_DIFFICULTY = "USER_LAST_SELECTED_DIFFICULTY"
        static let LAST_SELECTED_CATEGORY = "USER_LAST_SELECTED_CATEGORY"
        static let TUTORIAL_STAGE = "USER_TUTORIAL_STAGE"
        static let APPRATE_STATUS = "USER_APPRATE_STATUS"
        static let USER_LANGUAGE = "USER_LANGUAGE"
    }

    fileprivate let storage = UserDefaults.standard

    override func initService() {
        if (!storage.isFieldExists(KEY.LAST_SELECTED_DIFFICULTY)) {
            updateLastSelectedDifficulty(.normal)
        }

        if (!storage.isFieldExists(KEY.LAST_SELECTED_CATEGORY)) {
            updateLastSelectedCategoryType(.rightCutter)
        }

        if (!storage.isFieldExists(KEY.TUTORIAL_STAGE)) {
            updateTutorialStage(.never)
        }

        if (!storage.isFieldExists(KEY.APPRATE_STATUS)) {
            updateAppRateStatus(.never)
        }

        if (!storage.isFieldExists(KEY.USER_LANGUAGE)) {
            updateUserLanguage(Localize.currentLanguage())
        }
    }

    func getLastSelectedDifficulty() -> CipherDifficulty {
        return CipherDifficulty(rawValue: storage.getIntField(KEY.LAST_SELECTED_DIFFICULTY))!
    }

    func updateLastSelectedDifficulty(_ cipherDifficulty: CipherDifficulty) {
        storage.saveField(KEY.LAST_SELECTED_DIFFICULTY, value: cipherDifficulty.rawValue as AnyObject)
    }

    func getLastSelectedCategoryType() -> CipherType {
        return CipherType(rawValue: storage.getIntField(KEY.LAST_SELECTED_CATEGORY))!
    }

    func updateLastSelectedCategoryType(_ cipherType: CipherType) {
        storage.saveField(KEY.LAST_SELECTED_CATEGORY, value: cipherType.rawValue as AnyObject)
    }

    func getTutorialStage() -> TutorialStage {
        return TutorialStage(rawValue: storage.getIntField(KEY.TUTORIAL_STAGE))!
    }

    func updateTutorialStage(_ tutorialStage: TutorialStage) {
        storage.saveField(KEY.TUTORIAL_STAGE, value: tutorialStage.rawValue as AnyObject)
    }

    func getAppRateStatus() -> AppRateStatus {
        return AppRateStatus(rawValue: storage.getIntField(KEY.APPRATE_STATUS))!
    }

    func updateAppRateStatus(_ appRateStatus: AppRateStatus) {
        storage.saveField(KEY.APPRATE_STATUS, value: appRateStatus.rawValue as AnyObject)
    }

    func getUserLanguage() -> String {
        return storage.getStringField(KEY.USER_LANGUAGE)
    }

    func updateUserLanguage(_ language: String) {
        storage.saveField(KEY.USER_LANGUAGE, value: language as AnyObject)
    }
}
