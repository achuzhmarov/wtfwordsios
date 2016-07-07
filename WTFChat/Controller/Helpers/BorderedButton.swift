import Foundation

class BorderedButton: UIButton {
    let BORDER_WIDTH: CGFloat = 2
    let CORNER_RADIUS: CGFloat = 8

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.borderWidth = BORDER_WIDTH
        layer.borderColor = Color.CipheredDark.CGColor
        layer.cornerRadius = CORNER_RADIUS
        clipsToBounds = true

        setTitleColor(Color.Text, forState: .Normal)
        setTitleColor(Color.Text, forState: .Highlighted)

        addDiagonalGradient(Gradient.Ciphered)
    }
}