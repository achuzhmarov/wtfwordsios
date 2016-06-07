import Foundation

extension CoreSingleTalk {
    @NSManaged var cipherDifficulty: NSNumber?
    @NSManaged var cipherType: NSNumber?
    @NSManaged var wins: NSNumber?

    @NSManaged var messages: NSOrderedSet?

    @NSManaged func addMessagesObject(message: CoreSingleMessage)
    @NSManaged func removeMessagesObject(message: CoreSingleMessage)
    @NSManaged func addMessages(messages: NSOrderedSet)
    @NSManaged func removeMessages(messages: NSOrderedSet)
}
