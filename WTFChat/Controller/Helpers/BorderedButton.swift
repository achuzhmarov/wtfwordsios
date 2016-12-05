import Foundation

class BorderedButton: UIButton {
    fileprivate let BORDER_WIDTH: CGFloat = 2

    fileprivate var gradientLayer: CAGradientLayer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    private func initialize() {
        layer.borderWidth = BORDER_WIDTH
        layer.borderColor = Color.CipheredDark.cgColor
        layer.cornerRadius = CORNER_RADIUS_COEFF * bounds.height
        clipsToBounds = true

        setTitleColor(Color.Text, for: UIControlState())
        setTitleColor(Color.Text, for: .highlighted)

        gradientLayer = addDiagonalGradient(Gradient.Ciphered)
    }

    func updateGradient(_ colors: [CGColor]) {
        gradientLayer?.colors = colors
        layer.borderColor = colors[1]
    }
}
