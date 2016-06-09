import Foundation

class UIHelper {
    static func clearBackButton(navigationItem: UINavigationItem) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}
