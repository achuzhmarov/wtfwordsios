import Foundation

class UIHelper {
    static func clearBackButton(_ navigationItem: UINavigationItem) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
