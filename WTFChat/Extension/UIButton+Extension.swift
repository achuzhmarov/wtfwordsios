import Foundation

extension UIButton {
    func setTitleWithoutAnimation(_ title: String?) {
        UIView.setAnimationsEnabled(false)

        setTitle(title, for: .normal)

        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}
