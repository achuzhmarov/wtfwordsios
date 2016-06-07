import Foundation
import CoreData

extension CoreWord {

    @NSManaged var text: String?
    @NSManaged var wordType: NSNumber?
    @NSManaged var additional: String?
    @NSManaged var cipheredText: String?
    @NSManaged var wasCloseTry: NSNumber?

}
