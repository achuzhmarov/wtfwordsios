import Foundation

class TextGeneratorService: Service {
    var texts = [String]()

    override func initService() {
        let urlpath = NSBundle.mainBundle().pathForResource("go", ofType: "txt")
        let url = NSURL.fileURLWithPath(urlpath!)

        if let loadedData = Url.open(url) {
            texts = loadedData.componentsSeparatedByString("\n")

            print(texts)
        } else {
            print("error reading file")
        }
    }

    func getTextForLevel(level: Level) -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(texts.count)))
        return texts[randomIndex]
    }
}
