import Foundation

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
    private let BASE_RU_TEXT_PATH = "/Texts/ru/"

    private var textsMap = [CipherType: [Int: TextCategory]]()
    //private var textCategories = [TextCategory]()

    override func initService() {
        if let cipherFolders = getFilesList(BASE_RU_TEXT_PATH) {
            for cipherFolder in cipherFolders {
                loadCipherTexts(BASE_RU_TEXT_PATH, cipherFolder: cipherFolder)
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

    private func loadCipherTexts(basePath: String, cipherFolder: String) {
        let cipherType = getCipherTypeFromFolderName(cipherFolder)
        if (cipherType == nil) {
            return
        }

        textsMap[cipherType!] = [Int: TextCategory]()

        let difficultyFoldersPath = basePath + cipherFolder + "/"

        if let difficultyFolders = getFilesList(difficultyFoldersPath) {
            for difficultyFolder in difficultyFolders {
                loadTextCategoriesFromFolder(difficultyFoldersPath, difficultyFolder: difficultyFolder, cipherType: cipherType!)
            }
        }
    }

    private func getCipherTypeFromFolderName(cipherFolder: String) -> CipherType? {
        let cipherTypeString = cipherFolder.componentsSeparatedByString("_")[0]

        let cipherTypeRaw = Int(cipherTypeString)
        if (cipherTypeRaw == nil) {
            print("Can't get cipherType from folder name: \(cipherFolder)")
            return nil
        }

        let cipherType = CipherType(rawValue: cipherTypeRaw!)
        if (cipherType == nil) {
            print("Can't get cipherType from folder name: \(cipherFolder)")
            return nil
        }

        return cipherType
    }

    private func loadTextCategoriesFromFolder(basePath: String, difficultyFolder: String, cipherType: CipherType) {
        let textCategoriesFilesPath = basePath + difficultyFolder + "/"

        if let textCategoriesFiles = getFilesList(textCategoriesFilesPath) {
            for textCategoryFile in textCategoriesFiles {
                loadTextCategory(textCategoriesFilesPath, fileName: textCategoryFile, cipherType: cipherType)
            }
        }
    }

    private func loadTextCategory(basePath: String, fileName: String, cipherType: CipherType) {
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

            let lvlIds = getLvlIdsFromFileName(fileName)
            let step = messages.count / lvlIds.count

            for i in 0 ..< lvlIds.count {
                let newCategory = TextCategory()
                newCategory.title = title

                let leftBorder = step * i

                let rightBorder: Int
                if (i == lvlIds.count - 1) {
                    rightBorder = messages.count
                } else {
                    rightBorder = step * (i + 1)
                }

                for i in leftBorder ..< rightBorder {
                    newCategory.appendText(messages[i])
                }

                textsMap[cipherType]![lvlIds[i]] = newCategory
            }
        } else {
            print("error reading file \(url.path)")
        }
    }

    private func getLvlIdsFromFileName(fileName: String) -> [Int] {
        let levelsString = fileName.componentsSeparatedByString(".")[0]
        let levelsBorders = levelsString.componentsSeparatedByString("-")
        let lowLvlBorder = Int(levelsBorders[0])
        let highLvlBorder = Int(levelsBorders[1])

        if (lowLvlBorder == nil || highLvlBorder == nil) {
            print("Can't get levels from file name: \(fileName)")
            return [Int]()
        }

        var result = [Int]()

        for i in lowLvlBorder!...highLvlBorder! {
            result.append(i)
        }

        return result
    }

    private func getFileUrl(basePath: String, fileName: String) -> NSURL {
        let urlpath = NSBundle.mainBundle().pathForResource(basePath + fileName, ofType: "")
        return NSURL.fileURLWithPath(urlpath!)
    }

    func getTextCategoryForLevel(level: Level) -> TextCategory? {
        let cipherType = level.category.cipherType
        return textsMap[cipherType]![level.id]
    }
}
