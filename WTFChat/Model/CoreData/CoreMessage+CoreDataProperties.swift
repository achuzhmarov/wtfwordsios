import Foundation
import CoreData

extension CoreMessage {

    @NSManaged var timestamp: NSDate?
    @NSManaged var talkId: String?
    @NSManaged var lastUpdate: NSDate?
    @NSManaged var author: String?
    @NSManaged var deciphered: NSNumber?
    @NSManaged var cipherType: NSNumber?
    @NSManaged var cipherDifficulty: NSNumber?
    @NSManaged var exp: NSNumber?
    @NSManaged var timerSecs: NSNumber?
    @NSManaged var hintsUsed: NSNumber?
    @NSManaged var id: String?
    @NSManaged var isLocal: NSNumber?
    @NSManaged var extId: String?
    
    @NSManaged var words: NSOrderedSet?

    @NSManaged func addWordsObject(word: CoreWord)
    @NSManaged func removeWordsObject(word: CoreWord)
    @NSManaged func addWords(words: NSOrderedSet)
    @NSManaged func removeWords(words: NSOrderedSet)
}
