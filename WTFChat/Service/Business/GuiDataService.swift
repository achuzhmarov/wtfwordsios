import Foundation

class GuiDataService: Service {
    private struct KEY {
        static let LAST_SELECTED_DIFFICULTY = "USER_LAST_SELECTED_DIFFICULTY"
        static let LAST_SELECTED_CATEGORY = "USER_LAST_SELECTED_CATEGORY"
    }

    private let storage = NSUserDefaults.standardUserDefaults()

    override func initService() {
        if (!storage.isFieldExists(KEY.LAST_SELECTED_DIFFICULTY)) {
            updateLastSelectedDifficulty(.Normal)
        }

        if (!storage.isFieldExists(KEY.LAST_SELECTED_CATEGORY)) {
            updateLastSelectedCategoryType(.RightCutter)
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
}
