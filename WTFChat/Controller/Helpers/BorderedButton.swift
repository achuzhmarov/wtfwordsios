import Foundation

class BorderedButton: UIButton {
    private let BORDER_WIDTH: CGFloat = 2
    private let CORNER_RADIUS: CGFloat = 8

    private var gradientLayer: CAGradientLayer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        layer.borderWidth = BORDER_WIDTH
        layer.borderColor = Color.CipheredDark.CGColor
        layer.cornerRadius = CORNER_RADIUS
        clipsToBounds = true

        setTitleColor(Color.Text, forState: .Normal)
        setTitleColor(Color.Text, forState: .Highlighted)

        gradientLayer = addDiagonalGradient(Gradient.Ciphered)
    }

    func updateGradient(colors: [CGColor]) {
        gradientLayer?.colors = colors
    }
}