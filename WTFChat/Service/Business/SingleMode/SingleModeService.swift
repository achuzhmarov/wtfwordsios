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
        singleMessage.exp = expService.calculateExpForMessage(singleMessage)

        if (singleMessage.getMessageStatus() == .Success) {
            let level = singleMessage.level

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
        currentUserService.useHints(singleMessage.hintsUsed)
    }

    func isLevelAvailable(level: Level) -> Bool {
        //TODO - for testing
        return true

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
