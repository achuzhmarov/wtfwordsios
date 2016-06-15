import Foundation

class CoreLevelService: Service {
    private let CORE_LEVEL_CLASS_NAME = "CoreLevel"

    private let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func updateLevel(level: Level) {
        level.updateCoreLevel()
        coreDataService.saveContext()
    }

    func createLevelInCategory(category: SingleModeCategory, level: Level) {
        let newCoreLevel = coreDataService.createObject(CORE_LEVEL_CLASS_NAME) as! CoreLevel
        level.setCoreLevel(newCoreLevel)
        level.updateCoreLevel()

        level.category = category
        category.appendLevel(level)

        coreDataService.saveContext()
    }
}
