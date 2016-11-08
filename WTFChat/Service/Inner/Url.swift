import Foundation

class Url {
    class func open(_ url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print(error.code)
            return nil
        }
    }

    class func save(_ url: URL, fileContent: String) -> Bool {

        do {
            try fileContent.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch let error as NSError {
            print(error.code)
            return false
        }
    }
}
