import Foundation
import CoreData

class CoreLevel: NSManagedObject {
    func updateFromLevel(level: Level) {
        self.id = level.id
        self.cleared = level.cleared
        self.clearedDifficulty = level.clearedDifficulty?.rawValue
    }

    func getLevel() -> Level {
        let enumClearedDifficulty = self.clearedDifficulty != nil ?
                CipherDifficulty(rawValue: Int(self.clearedDifficulty!)) : nil

        let level = Level(
            id: Int(self.id),
            cleared: Bool(self.cleared),
            clearedDifficulty: enumClearedDifficulty
        )

        level.setCoreLevel(self)

        return level
    }
}
