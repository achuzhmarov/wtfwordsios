import Foundation

extension NSError {
    convenience init(code: Int, message: String) {
        self.init(domain:"com.artemchuzhmarov", code: code, userInfo:[NSLocalizedDescriptionKey : message])
    }
}