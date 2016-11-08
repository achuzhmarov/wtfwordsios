import Foundation

class Level {
    var id: Int
    var cleared: Bool
    var clearedDifficulty: CipherDifficulty?
    var category: SingleModeCategory!

    fileprivate var coreLevel: CoreLevel!

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

    func setCoreLevel(_ coreLevel: CoreLevel) {
        self.coreLevel = coreLevel
    }

    func isClearedForDifficulty(_ difficulty: CipherDifficulty) -> Bool {
        if (cleared) {
            switch difficulty {
                case .easy:
                    return true
                case .normal:
                    return clearedDifficulty == .normal || clearedDifficulty == .hard
                case .hard:
                    return clearedDifficulty == .hard
            }
        } else {
            return false
        }
    }
}
