import Foundation

class MenuButton: UIButton {
    let CORNER_RADIUS: CGFloat = 8

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.cornerRadius = CORNER_RADIUS
        clipsToBounds = true

        setTitleColor(UIColor.black, for: UIControlState())
        setTitleColor(UIColor.black, for: .highlighted)

        layer.backgroundColor = UIColor.white.cgColor
    }
}
