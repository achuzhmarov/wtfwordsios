import Foundation

class LevelService: Service {
    private let FIRST_LEVEL_ID_IN_CATEGORY = 1

    private let coreLevelService: CoreLevelService

    init(coreLevelService: CoreLevelService) {
        self.coreLevelService = coreLevelService
    }

    func updateLevel(level: Level) {
        coreLevelService.updateLevel(level)
    }

    func getPreviousLevel(level: Level) -> Level? {
        let category = level.category
        let previousLevelId = level.id - 1
        return category.getLevelById(previousLevelId)
    }
}
