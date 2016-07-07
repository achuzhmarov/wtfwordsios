import Foundation

class MenuButton: UIButton {
    let CORNER_RADIUS: CGFloat = 8

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.cornerRadius = CORNER_RADIUS
        clipsToBounds = true

        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.blackColor(), forState: .Highlighted)

        layer.backgroundColor = UIColor.whiteColor().CGColor
    }
}