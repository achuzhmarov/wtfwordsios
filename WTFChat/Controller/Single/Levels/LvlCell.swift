import Foundation

class LvlCell: UICollectionViewCell {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    @IBOutlet weak var titleLabel: UILabel!

    private var level: Level!

    private var gradientLayer: CAGradientLayer?

    private let CORNER_RADIUS_COEFF: CGFloat = 0.25

    private func initStyle() {
        titleLabel.textColor = Color.Text

        layer.cornerRadius = self.bounds.size.width * CORNER_RADIUS_COEFF

        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        gradientLayer?.removeFromSuperlayer()

        backgroundColor = UIColor.clearColor()
    }

    func updateLevel(level: Level) {
        initStyle()

        self.level = level

        if (level.cleared) {
            setClearedState()
        } else if singleModeService.isLevelAvailable(level) {
            setAvailableState()
        } else {
            setIgnoredState()
        }
    }

    private func setClearedState() {
        titleLabel.text = String(level.id)

        let gradient = Gradient.getLevelGradientByDifficulty(level.clearedDifficulty!)
        gradientLayer = addDiagonalGradient(gradient)
    }

    private func setAvailableState() {
        titleLabel.text = String(level.id)

        gradientLayer = addDiagonalGradient(Gradient.Ciphered)
    }

    private func setIgnoredState() {
        titleLabel.text = Emoji.LOCK

        gradientLayer = addDiagonalGradient(Gradient.Ignored)
        //layer.backgroundColor = Color.Ignore.CGColor
    }
}
