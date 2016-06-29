import Foundation

class SingleModeCategoryService: Service {
    private let LVLS_PER_CATEGORY = 24

    private let coreSingleModeCategoryService: CoreSingleModeCategoryService
    private let coreLevelService: CoreLevelService

    private var categories = [SingleModeCategory]()

    init(coreSingleModeCategoryService: CoreSingleModeCategoryService, coreLevelService: CoreLevelService) {
        self.coreSingleModeCategoryService = coreSingleModeCategoryService
        self.coreLevelService = coreLevelService
    }

    override func initService() {
        self.categories = coreSingleModeCategoryService.getAll()

        for cipherType in CipherType.getAll() {
            createSingleModeCategoryIfNotExists(cipherType)
        }
    }

    private func createSingleModeCategoryIfNotExists(cipherType: CipherType) {
        for category in categories {
            if (category.cipherType == cipherType) {
                return
            }
        }

        createSingleModeCategory(cipherType)
    }

    private func createSingleModeCategory(cipherType: CipherType) {
        let category = SingleModeCategory(cipherType: cipherType)

        coreSingleModeCategoryService.createSingleModeCategory(category)

        for lvlId in 1...LVLS_PER_CATEGORY {
            createLevelInCategory(category, id: lvlId)
        }

        self.categories.append(category)
    }

    private func createLevelInCategory(category: SingleModeCategory, id: Int) -> Level {
        let level = Level(id: id)
        coreLevelService.createLevelInCategory(category, level: level)

        return level
    }

    func getCategory(cipherType: CipherType) -> SingleModeCategory? {
        for category in categories {
            if (category.cipherType == cipherType) {
                return category
            }
        }

        return nil
    }

    func getPreviousCategory(targetCategory: SingleModeCategory) -> SingleModeCategory? {
        let firstCategory = categories[0]
        if targetCategory.cipherType == firstCategory.cipherType {
            return nil
        }

        var previousCategory = firstCategory

        for category in categories {
            if (category.cipherType == targetCategory.cipherType) {
                break
            }

            previousCategory = category
        }

        return previousCategory
    }

    /*func updateSingleModeCategory(category: SingleModeCategory) {
        coreSingleModeCategoryService.updateSingleModeCategory(category)
    }*/
}
