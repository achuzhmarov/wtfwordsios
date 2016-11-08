import Foundation

class SingleModeCategoryService: Service {
    fileprivate let LVLS_PER_CATEGORY = 24

    fileprivate let coreSingleModeCategoryService: CoreSingleModeCategoryService
    fileprivate let coreLevelService: CoreLevelService

    fileprivate var categories = [SingleModeCategory]()

    init(coreSingleModeCategoryService: CoreSingleModeCategoryService, coreLevelService: CoreLevelService) {
        self.coreSingleModeCategoryService = coreSingleModeCategoryService
        self.coreLevelService = coreLevelService
    }

    override func initServiceOnMain() {
        self.categories = coreSingleModeCategoryService.getAll()

        for cipherType in CipherType.getAll() {
            createSingleModeCategoryIfNotExists(cipherType)
        }
    }

    fileprivate func createSingleModeCategoryIfNotExists(_ cipherType: CipherType) {
        for category in categories {
            if (category.cipherType == cipherType) {
                return
            }
        }

        createSingleModeCategory(cipherType)
    }

    fileprivate func createSingleModeCategory(_ cipherType: CipherType) {
        let category = SingleModeCategory(cipherType: cipherType)

        coreSingleModeCategoryService.createSingleModeCategory(category)

        for lvlId in 1...LVLS_PER_CATEGORY {
            createLevelInCategory(category, id: lvlId)
        }

        self.categories.append(category)
    }

    fileprivate func createLevelInCategory(_ category: SingleModeCategory, id: Int) -> Level {
        let level = Level(id: id)

        //TODO - test code for screenshots
        /*if (id == 1 || id == 2 || id == 4 || id == 7 || id == 8 || id == 10 || id == 11 || id == 12) {
            level.cleared = true
            level.clearedDifficulty = .Normal
        } else if (id == 5 || id == 6 || id == 3 || id == 9 || id == 13) {
            level.cleared = true
            level.clearedDifficulty = .Easy
        }*/

        coreLevelService.createLevelInCategory(category, level: level)

        return level
    }

    func getCategory(_ cipherType: CipherType) -> SingleModeCategory? {
        for category in categories {
            if (category.cipherType == cipherType) {
                return category
            }
        }

        return nil
    }

    func getPreviousCategory(_ targetCategory: SingleModeCategory) -> SingleModeCategory? {
        let firstCategory = categories[0]
        if targetCategory.cipherType == firstCategory.cipherType {
            return nil
        }

        for i in 0 ..< categories.count {
            if (categories[i].cipherType == targetCategory.cipherType) {
                return categories[i-1]
            }
        }

        return nil
    }

    func getNextCategory(_ targetCategory: SingleModeCategory) -> SingleModeCategory? {
        let lastCategory = categories.last!
        if targetCategory.cipherType == lastCategory.cipherType {
            return nil
        }

        for i in 0 ..< categories.count {
            if (categories[i].cipherType == targetCategory.cipherType) {
                return categories[i+1]
            }
        }

        return nil
    }

    func isCategoryCleared(_ category: SingleModeCategory, difficulty: CipherDifficulty) -> Bool {
        for level in category.levels {
            if (!level.cleared) {
                return false
            }

            if (level.clearedDifficulty!.rawValue < difficulty.rawValue) {
                return false
            }
        }

        return true
    }

    /*func updateSingleModeCategory(category: SingleModeCategory) {
        coreSingleModeCategoryService.updateSingleModeCategory(category)
    }*/
}
