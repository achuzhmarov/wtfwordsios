import Foundation

class BorderedButton: UIButton {
    let BORDER_WIDTH: CGFloat = 2
    let CORNER_RADIUS: CGFloat = 8
    let VERTICAL_PADDING: CGFloat = 8
    let HORIZONTAL_PADDING: CGFloat = 24

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let mainColor = tintColor
        //let mainColor = Color.Ciphered

        layer.borderWidth = BORDER_WIDTH
        layer.borderColor = mainColor.CGColor
        layer.cornerRadius = CORNER_RADIUS
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(
            top: VERTICAL_PADDING,
            left: HORIZONTAL_PADDING,
            bottom: VERTICAL_PADDING,
            right: HORIZONTAL_PADDING
        )
        setTitleColor(mainColor, forState: .Normal)
        setTitleColor(Color.Font, forState: .Highlighted)
        setBackgroundImage(UIImage(color: mainColor), forState: .Highlighted)
    }
}