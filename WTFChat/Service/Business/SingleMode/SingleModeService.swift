import Foundation

enum StarStatus : Int {
    case NoChange = 0
    case EarnStar
    case Mastered
}

class SingleModeService: Service {
    private let categoryService: SingleModeCategoryService
    private let levelService: LevelService
    private let expService: ExpService
    private let currentUserService: CurrentUserService

    init(singleModeCategoryService: SingleModeCategoryService,
         expService: ExpService,
         currentUserService: CurrentUserService,
         levelService: LevelService)
    {
        self.categoryService = singleModeCategoryService
        self.expService = expService
        self.currentUserService = currentUserService
        self.levelService = levelService
    }

    func finishDecipher(singleMessage: SingleMessage) {
        let level = singleMessage.level
        let category = level.category
        let wasCategoryClearedOnEasy = categoryService.isCategoryCleared(category, difficulty: .Easy)
        let wasCategoryClearedOnNormal = categoryService.isCategoryCleared(category, difficulty: .Normal)
        let wasCategoryClearedOnHard = categoryService.isCategoryCleared(category, difficulty: .Hard)

        singleMessage.exp = expService.calculateExpForMessage(singleMessage)

        if (singleMessage.getMessageStatus() == .Success) {
            if (level.cleared) {
                if (level.clearedDifficulty!.rawValue < singleMessage.cipherDifficulty.rawValue) {
                    level.clearedDifficulty = singleMessage.cipherDifficulty
                }
            } else {
                level.cleared = true
                level.clearedDifficulty = singleMessage.cipherDifficulty
            }


            levelService.updateLevel(level)
        }

        currentUserService.earnSingleExp(singleMessage.exp)
        //currentUserService.useHints(singleMessage.hintsUsed)

        let categoryClearedOnEasy = categoryService.isCategoryCleared(category, difficulty: .Easy)
        let categoryClearedOnNormal = categoryService.isCategoryCleared(category, difficulty: .Normal)
        let categoryClearedOnHard = categoryService.isCategoryCleared(category, difficulty: .Hard)

        if (categoryClearedOnHard && !wasCategoryClearedOnHard) {
            category.hasJustClearedOnHard = true
        } else if (categoryClearedOnNormal && !wasCategoryClearedOnNormal) {
            category.hasJustClearedOnNormal = true
        } else if (categoryClearedOnEasy && !wasCategoryClearedOnEasy) {
            category.hasJustClearedOnEasy = true
        }
    }

    func isLevelAvailable(level: Level) -> Bool {
        if let previousLevel = levelService.getPreviousLevel(level) {
            return previousLevel.cleared
        } else if let previousCategory = categoryService.getPreviousCategory(level.category) {
            return previousCategory.getLastLevel().cleared
        } else {
            //first level
            return true
        }
    }
}
