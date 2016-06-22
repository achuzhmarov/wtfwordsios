import Foundation

class Url {
    class func open(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print(error.code)
            return nil
        }
    }

    class func save(url: NSURL, fileContent: String) -> Bool {

        do {
            try fileContent.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            return true
        } catch let error as NSError {
            print(error.code)
            return false
        }
    }
}
