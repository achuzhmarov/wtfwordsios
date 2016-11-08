import Foundation
import CoreData

class CoreLevel: NSManagedObject {
    func updateFromLevel(_ level: Level) {
        self.id = NSNumber(level.id)
        self.cleared = level.cleared as NSNumber
        self.clearedDifficulty = level.clearedDifficulty?.rawValue as NSNumber?
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
