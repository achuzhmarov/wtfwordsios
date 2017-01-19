import Foundation
import NVActivityIndicatorView
import Localize_Swift

class BaseVC: UIViewController, NVActivityIndicatorViewable {
    private let LOADING_TEXT = "Loading..."

    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func startLoader() {
        startLoader(LOADING_TEXT)
    }

    func startLoader(_ message: String) {
        let size = CGSize(width: 30, height: 30)
        startAnimating(size, message: message.localized(), type: NVActivityIndicatorType(rawValue: 6)!)
    }

    func stopLoader() {
        stopAnimating()
    }
}
