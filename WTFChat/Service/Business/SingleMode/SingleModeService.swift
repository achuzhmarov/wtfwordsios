import Foundation

enum StarStatus : Int {
    case noChange = 0
    case earnStar
    case mastered
}

class SingleModeService: Service {
    fileprivate let categoryService: SingleModeCategoryService
    fileprivate let levelService: LevelService
    fileprivate let expService: ExpService
    fileprivate let currentUserService: CurrentUserService

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

    func finishDecipher(_ singleMessage: SingleMessage) {
        let level = singleMessage.level
        let category = level?.category
        let wasCategoryClearedOnEasy = categoryService.isCategoryCleared(category!, difficulty: .easy)
        let wasCategoryClearedOnNormal = categoryService.isCategoryCleared(category!, difficulty: .normal)
        let wasCategoryClearedOnHard = categoryService.isCategoryCleared(category!, difficulty: .hard)

        singleMessage.exp = expService.calculateExpForMessage(singleMessage)

        if (singleMessage.getMessageStatus() == .success) {
            if (level?.cleared)! {
                if ((level?.clearedDifficulty!.rawValue)! < singleMessage.cipherDifficulty.rawValue) {
                    level?.clearedDifficulty = singleMessage.cipherDifficulty
                }
            } else {
                level?.cleared = true
                level?.clearedDifficulty = singleMessage.cipherDifficulty
            }


            levelService.updateLevel(level!)
        }

        currentUserService.earnSingleExp(singleMessage.exp)
        //currentUserService.useHints(singleMessage.hintsUsed)

        let categoryClearedOnEasy = categoryService.isCategoryCleared(category!, difficulty: .easy)
        let categoryClearedOnNormal = categoryService.isCategoryCleared(category!, difficulty: .normal)
        let categoryClearedOnHard = categoryService.isCategoryCleared(category!, difficulty: .hard)

        if (categoryClearedOnHard && !wasCategoryClearedOnHard) {
            category?.hasJustClearedOnHard = true
        } else if (categoryClearedOnNormal && !wasCategoryClearedOnNormal) {
            category?.hasJustClearedOnNormal = true
        } else if (categoryClearedOnEasy && !wasCategoryClearedOnEasy) {
            category?.hasJustClearedOnEasy = true
        }
    }

    func isLevelAvailable(_ level: Level) -> Bool {
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
