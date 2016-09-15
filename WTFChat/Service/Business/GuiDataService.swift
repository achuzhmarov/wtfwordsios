import Foundation

enum TutorialStage: Int {
    case Never = 0, DecipherGuess, DecipherCloseTry, DecipherCloseTryHint, DecipherHint, DecipherRest, Finished, Skipped
}

class GuiDataService: Service {
    private struct KEY {
        static let LAST_SELECTED_DIFFICULTY = "USER_LAST_SELECTED_DIFFICULTY"
        static let LAST_SELECTED_CATEGORY = "USER_LAST_SELECTED_CATEGORY"
        static let TUTORIAL_STAGE = "USER_TUTORIAL_STAGE"
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
}
