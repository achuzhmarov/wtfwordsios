import Foundation
import CoreData

class CoreWord: NSManagedObject {
    func updateFromWord(word: Word) {
        self.text = word.text
        self.additional = word.additional
        self.wordType = word.type.rawValue
        self.cipheredText = word.cipheredText
        self.wasCloseTry = word.wasCloseTry
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
