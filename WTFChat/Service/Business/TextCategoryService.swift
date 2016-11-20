import Foundation
import Localize_Swift

enum TextDifficulty : Int {
    case easy = 0
    case normal
    case hard

    var levelsCount : Int {
        get {
            switch self {
            case .easy:
                return 6
            case .normal:
                return 12
            case .hard:
                return 6
            }
        }
    }

    var firstLevelId: Int {
        get {
            switch self {
            case .easy:
                return 1
            case .normal:
                return 1 + TextDifficulty.easy.levelsCount
            case .hard:
                return 1 + TextDifficulty.easy.levelsCount + TextDifficulty.normal.levelsCount
            }
        }
    }

    var levelsPerLength : Int {
        get {
            return self.levelsCount / 3
        }
    }

    static func getAll() -> [TextDifficulty] {
        return [.easy, .normal, .hard]
    }
}

enum TextLength : Int {
    case short = 0
    case medium
    case long

    static func getAll() -> [TextLength] {
        return [.short, .medium, .long]
    }
}

enum TextLanguage : Int {
    case en = 0
    case ru

    static func getAll() -> [TextLanguage] {
        return [.en, .ru]
    }

    var description : String {
        get {
            switch self {
            case .en:
                return "en"
            case .ru:
                return "ru"
            }
        }
    }

    var textPath : String {
        get {
            switch self {
            case .en:
                return "/Texts/en/"
            case .ru:
                return "/Texts/ru/"
            }
        }
    }

    var letters : String {
        get {
            switch self {
            case .en:
                return "abcdefghijklmnopqrstuvwxyz"
            case .ru:
                return "абвгдежзиклмнопрстуфхцчшщъыьэюя"
            }
        }
    }

    static func getCurrentLanguage() -> TextLanguage {
        return getLanguageByString(Localize.currentLanguage())
    }

    static func getNextLanguage() -> TextLanguage {
        let currentLanguage = getLanguageByString(Localize.currentLanguage())
        var wasPrevious = false

        for language in TextLanguage.getAll() {
            if (wasPrevious) {
                return language
            } else if (language == currentLanguage) {
                wasPrevious = true
            }
        }

        return TextLanguage.getAll()[0]
    }

    static func getRandomLetter() -> String {
        let currentLanguage = getCurrentLanguage()
        let letters = currentLanguage.letters
        let randomIndex = Int(arc4random_uniform(UInt32(letters.characters.count)))
        return letters[randomIndex]
    }

    static func getLanguageByString(_ langString: String) -> TextLanguage {
        if (langString == "ru") {
            return .ru
        } else {
            return .en
        }
    }

    var buttonTitle : String {
        get {
            switch self {
            case .en:
                return "Language: English"
            case .ru:
                return "Язык: Русский"
            }
        }
    }
}

class TextCategory {
    var title: String = ""
    fileprivate var texts = [String]()
    fileprivate var currentMessage: String? = nil
    fileprivate var usedIndexes = Set<Int>()

    func appendText(_ text: String) {
        self.texts.append(text)
    }

    func getMessage() -> String {
        if let message = currentMessage {
            return message
        } else {
            updateMessage()
            return currentMessage!
        }
    }

    func updateMessage() {
        //clear usedIndexes if full
        if (usedIndexes.count == texts.count) {
            usedIndexes = Set<Int>()
        }

        var textIndex = getRandomIndex()

        while usedIndexes.contains(textIndex) {
            textIndex = getRandomIndex()
        }

        usedIndexes.insert(textIndex)

        currentMessage = texts[textIndex]
    }

    fileprivate func getRandomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(texts.count)))
    }
}

class TextCategoryService: Service {
    let guiDataService: GuiDataService

    fileprivate let WIKI_TITLE_INDEX = 0
    fileprivate let TITLE_INDEX = 1

    fileprivate var textsMap = [TextLanguage: [TextDifficulty: [TextLength: [TextCategory]]]]()

    fileprivate let textLengths = TextLength.getAll()

    var isReadyForLanguage = [TextLanguage: Bool]()
    var isLoadingLanguage = [TextLanguage: Bool]()

    init(guiDataService: GuiDataService) {
        self.guiDataService = guiDataService
    }

    override func initService() {
        for language in TextLanguage.getAll() {
            isReadyForLanguage[language] = false
            isLoadingLanguage[language] = false
        }

        let currentLanguage = TextLanguage.getLanguageByString(guiDataService.getUserLanguage())
        loadTextsForLanguage(currentLanguage)
    }

    func loadTextsForLanguage(_ language: TextLanguage) {
        if (isLoadingLanguage[language]! || isReadyForLanguage[language]!) {
            return
        }

        isLoadingLanguage[language] = true

        textsMap[language] = [TextDifficulty: [TextLength: [TextCategory]]]()

        if let difficultyFolders = getFilesList(language.textPath) {
            for difficultyFolder in difficultyFolders {
                loadDifficultyTexts(language.textPath, difficultyFolder: difficultyFolder, language: language)
            }
        }

        isReadyForLanguage[language] = true
    }

    fileprivate func getFilesList(_ folderName: String) -> [String]? {
        let cipherFoldersPath = Bundle.main.resourcePath! + folderName
        let fileManager = FileManager.default

        do {
            let folders = try fileManager.contentsOfDirectory(atPath: cipherFoldersPath)
            return folders
        } catch {
            print(error)
            return nil
        }
    }

    fileprivate func loadDifficultyTexts(_ basePath: String, difficultyFolder: String, language: TextLanguage) {
        let difficulty = getDifficultyFromFolderName(difficultyFolder)
        if (difficulty == nil) {
            return
        }

        textsMap[language]![difficulty!] = [TextLength: [TextCategory]]()

        let textCategoriesFilesPath = basePath + difficultyFolder + "/"

        if let textCategoriesFiles = getFilesList(textCategoriesFilesPath) {
            for textCategoryFile in textCategoriesFiles {
                loadTextCategory(textCategoriesFilesPath, fileName: textCategoryFile, textDifficulty: difficulty!, language: language)
            }
        }
    }

    fileprivate func getDifficultyFromFolderName(_ difficultyFolder: String) -> TextDifficulty? {
        let difficultyFolderString = difficultyFolder.components(separatedBy: "_")[0]

        let difficultyRaw = Int(difficultyFolderString)
        if (difficultyRaw == nil) {
            print("Can't get difficulty from folder name: \(difficultyFolder)")
            return nil
        }

        let difficulty = TextDifficulty(rawValue: difficultyRaw!)
        if (difficulty == nil) {
            print("Can't get difficulty from folder name: \(difficultyFolder)")
            return nil
        }

        return difficulty
    }

    fileprivate func loadTextCategory(_ basePath: String, fileName: String, textDifficulty: TextDifficulty, language: TextLanguage) {
        let url = getFileUrl(basePath, fileName: fileName)

        if let loadedData = Url.open(url) {
            let texts = loadedData.components(separatedBy: "\n")
            var index = 0

            var messages = [String]()
            var title = ""

            for text in texts {
                if (index == WIKI_TITLE_INDEX) {
                    //do nothing
                } else if (index == TITLE_INDEX) {
                    title = text
                } else {
                    messages.append(text)
                }

                index += 1
            }

            messages = messages.sorted(by: {$0.characters.count < $1.characters.count})

            let step = messages.count / textLengths.count

            for i in 0 ..< textLengths.count {
                let newCategory = TextCategory()
                newCategory.title = title

                let leftBorder = step * i

                let rightBorder: Int
                if (i == textLengths.count - 1) {
                    rightBorder = messages.count
                } else {
                    rightBorder = step * (i + 1)
                }

                for i in leftBorder ..< rightBorder {
                    newCategory.appendText(messages[i])
                }

                if (textsMap[language]![textDifficulty]![textLengths[i]] == nil) {
                    textsMap[language]![textDifficulty]![textLengths[i]] = [TextCategory]()
                }

                textsMap[language]![textDifficulty]![textLengths[i]]!.append(newCategory)
            }
        } else {
            print("error reading file \(url.path)")
        }
    }

    fileprivate func getFileUrl(_ basePath: String, fileName: String) -> URL {
        let urlpath = Bundle.main.path(forResource: basePath + fileName, ofType: "")
        return URL(fileURLWithPath: urlpath!)
    }

    func getTextCategoryForLevel(_ level: Level) -> TextCategory? {
        let currentLanguage = TextLanguage.getCurrentLanguage()

        while !(isReadyForLanguage[currentLanguage]!) {
            usleep(1000)
        }

        let textDifficulty = getTextDifficultyForLevel(level)
        let textLength = getTextLengthForLevel(level, textDifficulty: textDifficulty)

        let texts = textsMap[currentLanguage]![textDifficulty]![textLength]!
        let textIndex = getTextIndexForLevel(level, textDifficulty: textDifficulty, textCount: texts.count)

        //print(String(textDifficulty) + " " + String(textLength) + " " + String(textIndex))

        return texts[textIndex]
    }

    fileprivate func getTextDifficultyForLevel(_ level: Level) -> TextDifficulty {
        if (level.id < TextDifficulty.normal.firstLevelId) {
            return .easy
        } else if (level.id < TextDifficulty.hard.firstLevelId) {
            return .normal
        } else {
            return .hard
        }
    }

    fileprivate func getTextLengthForLevel(_ level: Level, textDifficulty: TextDifficulty) -> TextLength {
        let levelCategory: Int = (level.id - textDifficulty.firstLevelId) / textDifficulty.levelsPerLength
        return TextLength(rawValue: levelCategory)!
    }

    fileprivate func getTextIndexForLevel(_ level: Level, textDifficulty: TextDifficulty, textCount: Int) -> Int {
        let cipherTypeRaw = level.category.cipherType.rawValue
        return (level.id - textDifficulty.firstLevelId + cipherTypeRaw * textDifficulty.levelsCount) % textCount
    }
}
