import Foundation

class MessageCipherService: Service {
    fileprivate let WORD_SPECIAL_SYMBOLS = ["'"]//, "-"]

    //дефис и длинное тире
    fileprivate let ADDITIONAL_EXCEPTIONS = ["-","—","/","«","»", "(", ")", "\""]

    fileprivate let DELIMITERS = CharacterSet(charactersIn: "  ")

    fileprivate let ROMAN_LETTERS = ["X","V","I"]

    fileprivate let currentUserService: CurrentUserService
    fileprivate let cipherService: CipherService

    init(currentUserService: CurrentUserService, cipherService: CipherService) {
        self.currentUserService = currentUserService
        self.cipherService = cipherService
    }

    func getCompareString(_ string: String) -> String {
        return string.uppercased().removeChars(WORD_SPECIAL_SYMBOLS).replace("Ё", with: "Е")
    }
    
    func decipher(_ message: Message, guessText: String) {
        let guessWords = guessText.characters.split {$0 == " "}.map { String($0) }
        
        let words = message.words
        
        for guessWord in guessWords {
            let guesses = parseGuessForCompare(guessWord)
            
            for guess in guesses {
                for word in words! {
                    if (word.type == WordType.new && getCompareString(word.text) == guess) {
                        word.type = WordType.success
                    }
                }
            }
        }
        
        checkDeciphered(message)
    }
    
    func wasCloseTry(_ word: Word, guessWords: [String]?) -> Bool {
        if (guessWords == nil) {
            return false
        }

        let closeDistance = getCloseDistanceForWord(word)

        for guessWord in guessWords! {
            let guesses = parseGuessForCompare(guessWord)
            
            for guess in guesses {
                if Tools.calcStringDistance(getCompareString(word.text), bStr: guess) <= closeDistance {
                    return true
                }
            }
        }
        
        return false
    }

    fileprivate func getCloseDistanceForWord(_ word: Word) -> Int {
        let charactersCount = word.text.characters.count

        if (charactersCount < 4) {
            return 0
        } else if (charactersCount < 8) {
            return 1
        } else if (charactersCount < 12) {
            return 2
        } else {
            return 3
        }
    }
    
    func parseGuessForCompare(_ guessWord: String) -> [String] {
        var result = [String]()
        var newWordText = ""
        var isLastLetter = true
        
        for uniChar in guessWord.unicodeScalars {
            if (isLastLetter) {
                if (isLetter(uniChar)) {
                    newWordText += String(uniChar)
                } else {
                    isLastLetter = false
                    
                    //add word to result
                    result.append(getCompareString(newWordText))
                    newWordText = ""
                    
                    //skip current symbol
                }
            } else {
                if (isLetter(uniChar)) {
                    isLastLetter = true
                    
                    //save letter to new word
                    newWordText = String(uniChar)
                } else {
                    //skip current symbol
                }
            }
        }
        
        if (isLastLetter) {
            result.append(getCompareString(newWordText))
        }
        
        return result
    }
    
    func decipher(_ message: Message, hintedWord: Word, closeTry: Bool = false) {
        if (closeTry) {
            hintedWord.type = WordType.closeTry
        } else {
            hintedWord.type = WordType.success
        }
        
        checkDeciphered(message)
    }
    
    fileprivate func checkDeciphered(_ message: Message) {
        if (message.countNew() == 0) {
            message.deciphered = true
            message.lastUpdate = Date()
        }
    }
    
    func failed(_ message: Message) {
        for word in message.words! {
            if (word.type == WordType.new) {
                if (word.wasCloseTry) {
                    word.type = WordType.closeTry
                } else {
                    word.type = WordType.failed
                }
            }
        }
        
        message.deciphered = true
    }
    
    func createMessage(_ talk: FriendTalk, text: String, cipherType: CipherType, cipherDifficulty: CipherDifficulty) -> RemoteMessage {
        let generatedMessage = createMessage(text, cipherType: cipherType, cipherDifficulty: cipherDifficulty)
        return addNewMessageToTalk(generatedMessage, talk: talk)
    }
    
    func addNewMessageToTalk(_ generatedMessage: Message, talk: FriendTalk) -> RemoteMessage {
        var author: String
        
        if (talk.isSingleMode) {
            author = talk.users[0]
        } else {
            author = currentUserService.getUserLogin()
        }
        
        let newMessage = RemoteMessage(
            baseMessage: generatedMessage,
            talkId: talk.id,
            author: author
        )
        
        newMessage.isLocal = true
        checkDeciphered(newMessage)
        
        talk.appendMessage(newMessage)
        
        return newMessage
    }

    func createMessage(_ text: String, cipherType: CipherType, cipherDifficulty: CipherDifficulty) -> Message {
        var preparedText = text.replace("\r", with: "\n")
        preparedText = preparedText.replace("\n\n", with: "\n")

        let strings = preparedText.characters.split {$0 == "\n"}.map { String($0) }
        
        var firstSentence = true
        
        var words = [Word]()
        
        for curString in strings {
            if (firstSentence) {
                firstSentence = false
            } else {
                words.append(Word.lineBreakWord())
            }

            let textWords = curString.components(separatedBy: DELIMITERS)
            
            var firstWord = true
            
            for textWord in textWords {
                if (firstWord) {
                    firstWord = false
                } else {
                    words.append(Word.delimiterWord())
                }
                
                words.append(contentsOf: createWords(textWord))
            }
        }
        
        let newMessage = Message(
            extId: UUID().uuidString,
            cipherType: cipherType,
            cipherDifficulty: cipherDifficulty,
            words: words
        )

        cipherService.cipherMessage(newMessage)
        checkDeciphered(newMessage)
        
        return newMessage
    }
    
    fileprivate func createWords(_ textWord: String) -> [Word] {
        var words = [Word]()
        
        var newWordText = ""
        var newWordAdditional = ""
        
        var isLastLetter = true
        
        for uniChar in textWord.unicodeScalars {
            if (isLastLetter) {
                if (isLetter(uniChar)) {
                    newWordText += String(uniChar)
                } else if ADDITIONAL_EXCEPTIONS.contains(String(uniChar)) {
                    isLastLetter = false

                    if (newWordText != "") {
                        words.append(Word(text: newWordText, additional: newWordAdditional, type: getWordType(newWordText)))
                    }

                    newWordText = ""
                    newWordAdditional = String(uniChar)

                } else {
                    isLastLetter = false

                    newWordAdditional += String(uniChar)
                }
            } else {
                if (isLetter(uniChar)) {
                    isLastLetter = true
                    
                    words.append(Word(text: newWordText, additional: newWordAdditional, type: getWordType(newWordText)))
                    
                    newWordText = String(uniChar)
                    newWordAdditional = ""
                } else {
                    newWordAdditional += String(uniChar)
                }
            }
        }
        
        words.append(Word(text: newWordText, additional: newWordAdditional, type: getWordType(newWordText)))
        
        return words
    }
    
    fileprivate func getWordType(_ newWordText: String) -> WordType {
        if (countLettersOnly(newWordText) <= 1) {
            return WordType.ignore
        } else if isRomanDate(newWordText) {
            return WordType.ignore
        } else {
            return WordType.new
        }
    }

    fileprivate func isRomanDate(_ text: String) -> Bool {
        for char in text.characters {
            if ROMAN_LETTERS.contains(String(char)) {
                continue
            } else {
                return false
            }
        }

        return true
    }
    
    fileprivate let letters = CharacterSet.letters
    fileprivate func isLetter(_ unicodeChar: UnicodeScalar) -> Bool {
        if isLetterOnly(unicodeChar) {
            return true
        } else {
            for wordSymbol in WORD_SPECIAL_SYMBOLS {
                if String(unicodeChar) == wordSymbol {
                    return true
                }
            }
        }
        
        return false
    }
    
    fileprivate func isLetterOnly(_ unicodeChar: UnicodeScalar) -> Bool {
        if letters.contains(UnicodeScalar(unicodeChar.value)!) {
            return true
        }
        
        return false
    }
    
    fileprivate func countLettersOnly(_ string: String) -> Int {
        var result = 0
        
        for char in string.unicodeScalars {
            if isLetterOnly(char) {
                result += 1
            }
        }
        
        return result
    }

    private let EASY_MODIFIER = 1.2
    private let HARD_MODIFIER = 1.5

    private let SECONDS_PER_WORD = 10.0
    private let WORD_COUNT_STEP = 5
    private let WORD_COUNT_MODIFIERS = [1, 0.8, 0.6, 0.4, 0.2]

    private let SECONDS_PER_LETTER = 2.0
    private let LETTER_COUNT_STEP = 30
    private let LETTER_COUNT_MODIFIERS = [1, 0.8, 0.6, 0.4, 0.2]

    func getTimerSeconds(_ message: Message) -> Int {
        var result = countWordSecs(message) + countLettersSecs(message)

        if (message.cipherDifficulty == .easy) {
            result *= EASY_MODIFIER
        } else if (message.cipherDifficulty == .hard) {
            result *= HARD_MODIFIER
        }

        print(message)
        print(countWordSecs(message))
        print(countLettersSecs(message))
        print(result)
        print(Int(result))

        return Int(result)
    }

    private func countWordSecs(_ message: Message) -> Double {
        var result = 0.0

        for i in 0 ..< message.countNew() {
            let modifierIndex = min(i / WORD_COUNT_STEP, WORD_COUNT_MODIFIERS.count - 1)
            result += SECONDS_PER_WORD * WORD_COUNT_MODIFIERS[modifierIndex]
        }

        return result
    }

    private func countLettersSecs(_ message: Message) -> Double {
        var result = 0.0

        for i in 0 ..< message.countLettersInCipheredWords() {
            let modifierIndex = min(i / LETTER_COUNT_STEP, LETTER_COUNT_MODIFIERS.count - 1)
            result += SECONDS_PER_LETTER * LETTER_COUNT_MODIFIERS[modifierIndex]
        }

        return result
    }
}
