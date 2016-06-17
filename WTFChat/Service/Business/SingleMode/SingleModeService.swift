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
            level.cleared = true
            level.clearedDifficulty = singleMessage.cipherDifficulty
            levelService.updateLevel(level)
        }

        currentUserService.earnSingleExp(singleMessage.exp)
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
