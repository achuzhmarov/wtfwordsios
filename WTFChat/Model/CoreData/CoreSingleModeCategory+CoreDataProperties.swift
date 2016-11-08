import Foundation

extension CoreSingleModeCategory {
    @NSManaged var cipherType: NSNumber?
    @NSManaged var levels: NSOrderedSet?

    @NSManaged func addLevelsObject(_ level: CoreLevel)
    @NSManaged func removeLevelsObject(_ level: CoreLevel)
    @NSManaged func addLevels(_ messages: NSOrderedSet)
    @NSManaged func removeLevels(_ messages: NSOrderedSet)
}
