import Foundation
import Localize_Swift

enum TutorialStage: Int {
    case Never = 0, DecipherGuess, DecipherCloseTry, DecipherCloseTryHint, DecipherHint, DecipherRest, Finished, Skipped
}

enum AppRateStatus: Int {
    case Never = 0, Enjoyed, Rated, NotEnjoyed, Feedback
}

class GuiDataService: Service {
    private struct KEY {
        static let LAST_SELECTED_DIFFICULTY = "USER_LAST_SELECTED_DIFFICULTY"
        static let LAST_SELECTED_CATEGORY = "USER_LAST_SELECTED_CATEGORY"
        static let TUTORIAL_STAGE = "USER_TUTORIAL_STAGE"
        static let APPRATE_STATUS = "USER_APPRATE_STATUS"
        static let USER_LANGUAGE = "USER_LANGUAGE"
    }

    private let storage = NSUserDefaults.standardUserDefaults()

    override func initService() {
        if (!storage.isFieldExists(KEY.LAST_SELECTED_DIFFICULTY)) {
            updateLastSelectedDifficulty(.Normal)
        }

        if (!storage.isFieldExists(KEY.LAST_SELECTED_CATEGORY)) {
            updateLastSelectedCategoryType(.RightCutter)
        }

        if (!storage.isFieldExists(KEY.TUTORIAL_STAGE)) {
            updateTutorialStage(.Never)
        }

        if (!storage.isFieldExists(KEY.APPRATE_STATUS)) {
            updateAppRateStatus(.Never)
        }

        if (!storage.isFieldExists(KEY.USER_LANGUAGE)) {
            updateUserLanguage(Localize.currentLanguage())
        }
    }

    func getLastSelectedDifficulty() -> CipherDifficulty {
        return CipherDifficulty(rawValue: storage.getIntField(KEY.LAST_SELECTED_DIFFICULTY))!
    }

    func updateLastSelectedDifficulty(cipherDifficulty: CipherDifficulty) {
        storage.saveField(KEY.LAST_SELECTED_DIFFICULTY, value: cipherDifficulty.rawValue)
    }

    func getLastSelectedCategoryType() -> CipherType {
        return CipherType(rawValue: storage.getIntField(KEY.LAST_SELECTED_CATEGORY))!
    }

    func updateLastSelectedCategoryType(cipherType: CipherType) {
        storage.saveField(KEY.LAST_SELECTED_CATEGORY, value: cipherType.rawValue)
    }

    func getTutorialStage() -> TutorialStage {
        return TutorialStage(rawValue: storage.getIntField(KEY.TUTORIAL_STAGE))!
    }

    func updateTutorialStage(tutorialStage: TutorialStage) {
        storage.saveField(KEY.TUTORIAL_STAGE, value: tutorialStage.rawValue)
    }

    func getAppRateStatus() -> AppRateStatus {
        return AppRateStatus(rawValue: storage.getIntField(KEY.APPRATE_STATUS))!
    }

    func updateAppRateStatus(appRateStatus: AppRateStatus) {
        storage.saveField(KEY.APPRATE_STATUS, value: appRateStatus.rawValue)
    }

    func getUserLanguage() -> String {
        return storage.getStringField(KEY.USER_LANGUAGE)
    }

    func updateUserLanguage(language: String) {
        storage.saveField(KEY.USER_LANGUAGE, value: language)
    }
}
