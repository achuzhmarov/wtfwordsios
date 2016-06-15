import Foundation

class Level {
    var id: Int
    var cleared: Bool
    var clearedDifficulty: CipherDifficulty?
    var category: SingleModeCategory!

    private var coreLevel: CoreLevel!

    init(id: Int, cleared: Bool = false, clearedDifficulty: CipherDifficulty? = nil) {
        self.id = id
        self.cleared = cleared
        self.clearedDifficulty = clearedDifficulty
    }

    func updateCoreLevel() {
        coreLevel.updateFromLevel(self)
    }

    func getCoreLevel() -> CoreLevel {
        return self.coreLevel
    }

    func setCoreLevel(coreLevel: CoreLevel) {
        self.coreLevel = coreLevel
    }

    func isClearedForDifficulty(difficulty: CipherDifficulty) -> Bool {
        if (cleared) {
            switch difficulty {
                case .Easy:
                    return true
                case .Normal:
                    return clearedDifficulty == .Normal || clearedDifficulty == .Hard
                case .Hard:
                    return clearedDifficulty == .Hard
            }
        } else {
            return false
        }
    }
}
