import Foundation
import CoreData

extension CoreMessage {

    @NSManaged var timestamp: Date?
    @NSManaged var talkId: String?
    @NSManaged var lastUpdate: Date?
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

    @NSManaged func addWordsObject(_ word: CoreWord)
    @NSManaged func removeWordsObject(_ word: CoreWord)
    @NSManaged func addWords(_ words: NSOrderedSet)
    @NSManaged func removeWords(_ words: NSOrderedSet)
}
