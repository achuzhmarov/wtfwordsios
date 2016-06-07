import Foundation

extension CoreSingleMessage {

    @NSManaged var timestamp: NSDate?
    @NSManaged var lastUpdate: NSDate?
    @NSManaged var deciphered: NSNumber?
    @NSManaged var cipherType: NSNumber?
    @NSManaged var cipherDifficulty: NSNumber?
    @NSManaged var exp: NSNumber?
    @NSManaged var timerSecs: NSNumber?
    @NSManaged var hintsUsed: NSNumber?
    @NSManaged var extId: String?

    @NSManaged var words: NSOrderedSet?

    @NSManaged func addWordsObject(word: CoreWord)
    @NSManaged func removeWordsObject(word: CoreWord)
    @NSManaged func addWords(words: NSOrderedSet)
    @NSManaged func removeWords(words: NSOrderedSet)
}