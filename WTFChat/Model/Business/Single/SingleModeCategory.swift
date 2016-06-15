import Foundation

class SingleModeCategory {
    var cipherType: CipherType
    var levels: [Level]

    private var coreSingleModeCategory: CoreSingleModeCategory!

    init(cipherType: CipherType, levels: [Level] = [Level]()) {
        self.cipherType = cipherType
        self.levels = levels
    }

    func appendLevel(level: Level) {
        levels.append(level)
        coreSingleModeCategory.addLevelsObject(level.getCoreLevel())
    }

    func setCoreSingleModeCategory(coreSingleModeCategory: CoreSingleModeCategory) {
        self.coreSingleModeCategory = coreSingleModeCategory
    }

    func updateCoreSingleModeCategory() {
        self.coreSingleModeCategory.updateFromSingleModeCategoryWithoutLevels(self)
    }

    func getLevelById(id: Int) -> Level? {
        if (id < 1 || id > levels.count) {
            return nil
        }

        return levels[id - 1]
    }

    func getLastLevel() -> Level {
        return levels[levels.count - 1]
    }
}
