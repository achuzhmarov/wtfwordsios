import Foundation

class TextCategory {
    var title: String = ""
    private var texts = [String]()

    func appendText(text: String) {
        self.texts.append(text)
    }

    func getRandomText() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(texts.count)))
        return texts[randomIndex]
    }
}

class TextCategoryService: Service {
    private let WIKI_TITLE_INDEX = 0
    private let TITLE_INDEX = 1
    private let BASE_RU_TEXT_PATH = "/Texts/ru/"

    private var textCategories = [TextCategory]()

    override func initService() {
        let docsPath = NSBundle.mainBundle().resourcePath! + BASE_RU_TEXT_PATH
        let fileManager = NSFileManager.defaultManager()

        do {
            let docsArray = try fileManager.contentsOfDirectoryAtPath(docsPath)

            for doc in docsArray {
                loadTextCategory(doc)
            }
        } catch {
            print(error)
        }

        /*for textCategory in TEXT_CATEGORIES {
            loadTextCategory(textCategory)
        }*/
    }

    private func loadTextCategory(fileName: String) {
        let newCategory = TextCategory()

        let url = getFileUrl(fileName)

        if let loadedData = Url.open(url) {
            let texts = loadedData.componentsSeparatedByString("\n")
            var index = 0

            for text in texts {
                if (index == WIKI_TITLE_INDEX) {
                    //do nothing
                } else if (index == TITLE_INDEX) {
                    newCategory.title = text
                } else {
                    newCategory.appendText(text)
                }

                index += 1
            }

            textCategories.append(newCategory)

            print(texts)
        } else {
            print("error reading file \(url.path)")
        }
    }

    private func getFileUrl(fileName: String) -> NSURL {
        let urlpath = NSBundle.mainBundle().pathForResource(BASE_RU_TEXT_PATH + fileName, ofType: "")
        return NSURL.fileURLWithPath(urlpath!)
    }

    func getTextCategoryForLevel(level: Level) -> TextCategory {
        let randomIndex = Int(arc4random_uniform(UInt32(textCategories.count)))
        return textCategories[randomIndex]
    }
}
