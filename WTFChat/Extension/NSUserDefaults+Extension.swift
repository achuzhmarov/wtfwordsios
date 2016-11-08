import Foundation

extension UserDefaults {
    func getStringField(_ key: String) -> String {
        return self.string(forKey: key)!
    }

    func getIntField(_ key: String) -> Int {
        return self.integer(forKey: key)
    }

    func getDateField(_ key: String) -> Date {
        if let date = self.object(forKey: key) as? Date {
            return date
        } else {
            return Date()
        }
    }

    func getBoolField(_ key: String) -> Bool {
        return self.bool(forKey: key)
    }

    func saveField(_ key: String, value: AnyObject) {
        self.setValue(value, forKey: key)
        self.synchronize()
    }

    func isFieldExists(_ key: String) -> Bool {
        if (self.string(forKey: key) != nil) {
            return true
        } else {
            return false
        }
    }
}
