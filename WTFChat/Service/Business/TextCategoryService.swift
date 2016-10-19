import Foundation
import Localize_Swift

enum TextDifficulty : Int {
    case Easy = 0
    case Normal
    case Hard

    var levelsCount : Int {
        get {
            switch self {
            case .Easy:
                return 6
            case .Normal:
                return 12
            case .Hard:
                return 6
            }
        }
    }

    var firstLevelId: Int {
        get {
            switch self {
            case .Easy:
                return 1
            case .Normal:
                return 1 + TextDifficulty.Easy.levelsCount
            case .Hard:
                return 1 + TextDifficulty.Easy.levelsCount + TextDifficulty.Normal.levelsCount
            }
        }
    }

    var levelsPerLength : Int {
        get {
            return self.levelsCount / 3
        }
    }

    static func getAll() -> [TextDifficulty] {
        return [.Easy, .Normal, .Hard]
    }
}

enum TextLength : Int {
    case Short = 0
    case Medium
    case Long

    static func getAll() -> [TextLength] {
        return [.Short, .Medium, .Long]
    }
}

enum TextLanguage : Int {
    case En = 0
    case Ru

    static func getAll() -> [TextLanguage] {
        return [.En, .Ru]
    }

    var description : String {
        get {
            switch self {
            case .En:
                return "en"
            case .Ru:
                return "ru"
            }
        }
    }

    var textPath : String {
        get {
            switch self {
            case .En:
                return "/Texts/en/"
            case .Ru:
                return "/Texts/ru/"
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

    private static func getLanguageByString(langString: String) -> TextLanguage {
        if (langString == "ru") {
            return .Ru
        } else {
            return .En
        }
    }

    var buttonTitle : String {
        get {
            switch self {
            case .En:
                return "Language: English"
            case .Ru:
                return "Язык: Русский"
            }
        }
    }
}

class TextCategory {
    var title: String = ""
    private var texts = [String]()
    private var currentMessage: String? = nil
    private var usedIndexes = Set<Int>()

    func appendText(text: String) {
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

    private func getRandomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(texts.count)))
    }
}

class TextCategoryService: Service {
    private let WIKI_TITLE_INDEX = 0
    private let TITLE_INDEX = 1

    private var textsMap = [TextLanguage: [TextDifficulty: [TextLength: [TextCategory]]]]()

    private let textLengths = TextLength.getAll()

    override func initService() {
        for language in TextLanguage.getAll() {
            loadTextsForLanguage(language)
        }
    }

    private func loadTextsForLanguage(language: TextLanguage) {
        textsMap[language] = [TextDifficulty: [TextLength: [TextCategory]]]()

        if let difficultyFolders = getFilesList(language.textPath) {
            for difficultyFolder in difficultyFolders {
                loadDifficultyTexts(language.textPath, difficultyFolder: difficultyFolder, language: language)
            }
        }
    }

    private func getFilesList(folderName: String) -> [String]? {
        let cipherFoldersPath = NSBundle.mainBundle().resourcePath! + folderName
        let fileManager = NSFileManager.defaultManager()

        do {
            let folders = try fileManager.contentsOfDirectoryAtPath(cipherFoldersPath)
            return folders
        } catch {
            print(error)
            return nil
        }
    }

    private func loadDifficultyTexts(basePath: String, difficultyFolder: String, language: TextLanguage) {
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

    private func getDifficultyFromFolderName(difficultyFolder: String) -> TextDifficulty? {
        let difficultyFolderString = difficultyFolder.componentsSeparatedByString("_")[0]

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

    private func loadTextCategory(basePath: String, fileName: String, textDifficulty: TextDifficulty, language: TextLanguage) {
        let url = getFileUrl(basePath, fileName: fileName)

        if let loadedData = Url.open(url) {
            let texts = loadedData.componentsSeparatedByString("\n")
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

            messages = messages.sort({$0.characters.count < $1.characters.count})

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

    private func getFileUrl(basePath: String, fileName: String) -> NSURL {
        let urlpath = NSBundle.mainBundle().pathForResource(basePath + fileName, ofType: "")
        return NSURL.fileURLWithPath(urlpath!)
    }

    func getTextCategoryForLevel(level: Level) -> TextCategory? {
        let currentLanguage = TextLanguage.getCurrentLanguage()

        let textDifficulty = getTextDifficultyForLevel(level)
        let textLength = getTextLengthForLevel(level, textDifficulty: textDifficulty)

        let texts = textsMap[currentLanguage]![textDifficulty]![textLength]!
        let textIndex = getTextIndexForLevel(level, textDifficulty: textDifficulty, textCount: texts.count)

        //print(String(textDifficulty) + " " + String(textLength) + " " + String(textIndex))

        return texts[textIndex]
    }

    private func getTextDifficultyForLevel(level: Level) -> TextDifficulty {
        if (level.id < TextDifficulty.Normal.firstLevelId) {
            return .Easy
        } else if (level.id < TextDifficulty.Hard.firstLevelId) {
            return .Normal
        } else {
            return .Hard
        }
    }

    private func getTextLengthForLevel(level: Level, textDifficulty: TextDifficulty) -> TextLength {
        let levelCategory: Int = (level.id - textDifficulty.firstLevelId) / textDifficulty.levelsPerLength
        return TextLength(rawValue: levelCategory)!
    }

    private func getTextIndexForLevel(level: Level, textDifficulty: TextDifficulty, textCount: Int) -> Int {
        let cipherTypeRaw = level.category.cipherType.rawValue
        return (level.id - textDifficulty.firstLevelId + cipherTypeRaw * textDifficulty.levelsCount) % textCount
    }
}
