import Foundation

class CoreLevelService: Service {
    fileprivate let CORE_LEVEL_CLASS_NAME = "CoreLevel"

    fileprivate let coreDataService: CoreDataService

    init(coreDataService: CoreDataService) {
        self.coreDataService = coreDataService
    }

    func updateLevel(_ level: Level) {
        level.updateCoreLevel()
        coreDataService.saveContext()
    }

    func createLevelInCategory(_ category: SingleModeCategory, level: Level) {
        let newCoreLevel = coreDataService.createObject(CORE_LEVEL_CLASS_NAME) as! CoreLevel
        level.setCoreLevel(newCoreLevel)
        level.updateCoreLevel()

        level.category = category
        category.appendLevel(level)

        coreDataService.saveContext()
    }
}
