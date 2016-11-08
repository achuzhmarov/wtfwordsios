import Foundation

class LevelService: Service {
    fileprivate let FIRST_LEVEL_ID_IN_CATEGORY = 1

    fileprivate let coreLevelService: CoreLevelService

    init(coreLevelService: CoreLevelService) {
        self.coreLevelService = coreLevelService
    }

    func updateLevel(_ level: Level) {
        coreLevelService.updateLevel(level)
    }

    func getPreviousLevel(_ level: Level) -> Level? {
        let category = level.category
        let previousLevelId = level.id - 1
        return category?.getLevelById(previousLevelId)
    }

    func getNextLevel(_ level: Level) -> Level? {
        let category = level.category
        let nextLevelId = level.id + 1
        return category?.getLevelById(nextLevelId)
    }
}
