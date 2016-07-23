import Foundation

extension NSUserDefaults {
    func getStringField(key: String) -> String {
        return self.stringForKey(key)!
    }

    func getIntField(key: String) -> Int {
        return self.integerForKey(key)
    }

    func getDateField(key: String) -> NSDate {
        if let date = self.objectForKey(key) as? NSDate {
            return date
        } else {
            return NSDate()
        }
    }

    func getBoolField(key: String) -> Bool {
        return self.boolForKey(key)
    }

    func saveField(key: String, value: AnyObject) {
        self.setValue(value, forKey: key)
        self.synchronize()
    }

    func isFieldExists(key: String) -> Bool {
        if (self.stringForKey(key) != nil) {
            return true
        } else {
            return false
        }
    }
}
