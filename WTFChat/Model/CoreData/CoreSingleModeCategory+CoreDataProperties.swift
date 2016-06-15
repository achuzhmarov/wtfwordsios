import Foundation

extension CoreSingleModeCategory {
    @NSManaged var cipherType: NSNumber?
    @NSManaged var levels: NSOrderedSet?

    @NSManaged func addLevelsObject(level: CoreLevel)
    @NSManaged func removeLevelsObject(level: CoreLevel)
    @NSManaged func addLevels(messages: NSOrderedSet)
    @NSManaged func removeLevels(messages: NSOrderedSet)
}
