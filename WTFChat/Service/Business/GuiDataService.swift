import Foundation
import Localize_Swift

enum TutorialStageHardcore: Int {
    case never = 0, decipherGuess, decipherCloseTry, decipherCloseTryHint, decipherHint, decipherRest, finished, skipped
}

enum TutorialStage: Int {
    case never = 0, decipherFirstWord, finished, skipped
}

enum WtfStage: Int {
    case beginning = 0, gotHint, gotLetters, gotSolve, gotShake
}

enum AppRateStatus: Int {
    case never = 0, enjoyed, rated, skipRateUpdate, notEnjoyed, feedback, skipFeedbackUpdate
}

class GuiDataService: Service {
    fileprivate struct KEY {
        static let LAST_SELECTED_DIFFICULTY = "USER_LAST_SELECTED_DIFFICULTY"
        static let LAST_SELECTED_CATEGORY = "USER_LAST_SELECTED_CATEGORY"
        static let TUTORIAL_STAGE_HARDCORE = "USER_TUTORIAL_STAGE" //TODO - deprecated
        static let TUTORIAL_STAGE = "USER_TUTORIAL_STAGE_NORMAL"
        static let APPRATE_STATUS = "USER_APPRATE_STATUS"
        static let USER_LANGUAGE = "USER_LANGUAGE"
        static let WTF_STAGE = "USER_WTF_STAGE"
        static let WRONG_LETTERS_HINT = "USER_WRONG_LETTERS_HINT"
        static let LAST_VERSION = "LAST_VERSION"
    }

    fileprivate let storage = UserDefaults.standard

    override func initService() {
        if (!storage.isFieldExists(KEY.LAST_SELECTED_DIFFICULTY)) {
            updateLastSelectedDifficulty(.normal)
        }

        if (!storage.isFieldExists(KEY.LAST_SELECTED_CATEGORY)) {
            updateLastSelectedCategoryType(.rightCutter)
        }

        if (!storage.isFieldExists(KEY.TUTORIAL_STAGE_HARDCORE)) {
            updateTutorialStageHardcore(.never)
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

        if (!storage.isFieldExists(KEY.WTF_STAGE)) {
            updateWtfStage(.beginning)
        }

        if (!storage.isFieldExists(KEY.WRONG_LETTERS_HINT)) {
            updateWrongLettersHint(false)
        }

        if (!storage.isFieldExists(KEY.LAST_VERSION)) {
            storage.saveField(KEY.LAST_VERSION, value: "1.0" as AnyObject)
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

    func getTutorialStageHardcore() -> TutorialStageHardcore {
        return TutorialStageHardcore(rawValue: storage.getIntField(KEY.TUTORIAL_STAGE_HARDCORE))!
    }

    func updateTutorialStageHardcore(_ tutorialStage: TutorialStageHardcore) {
        storage.saveField(KEY.TUTORIAL_STAGE_HARDCORE, value: tutorialStage.rawValue as AnyObject)
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

    func getWtfStage() -> String {
        return storage.getStringField(KEY.WTF_STAGE)
    }

    func updateWtfStage(_ wtfStage: WtfStage) {
        storage.saveField(KEY.WTF_STAGE, value: wtfStage as AnyObject)
    }

    func getWrongLettersHint() -> Bool {
        return storage.getBoolField(KEY.WRONG_LETTERS_HINT)
    }

    func updateWrongLettersHint(_ wrongLettersHint: Bool) {
        storage.saveField(KEY.WRONG_LETTERS_HINT, value: wrongLettersHint as AnyObject)
    }

    func isVersionChanged() -> Bool {
        let lastVersion = storage.getStringField(KEY.LAST_VERSION)
        let currentVersion = Bundle.main.releaseVersionNumber
        return (lastVersion != currentVersion)
    }

    func updateLastVersion() {
        let currentVersion = Bundle.main.releaseVersionNumber
        storage.saveField(KEY.LAST_VERSION, value: currentVersion as AnyObject)
    }
}
