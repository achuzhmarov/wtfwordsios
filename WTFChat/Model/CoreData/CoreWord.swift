import Foundation
import CoreData

class CoreWord: NSManagedObject {
    func updateFromWord(_ word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.wordType = word.type.rawValue as NSNumber?
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry as NSNumber?
    }
    
    func getWord() -> Word? {
        let enumWordType = WordType(rawValue: Int(self.wordType!))

        return Word(
            text: self.text!,
            additional: self.additional!,
            type: enumWordType!,
            cipheredText: self.cipheredText!,
            wasCloseTry: Bool(self.wasCloseTry!)
        )
    }
}
