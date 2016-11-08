import Foundation

class LvlCell: UICollectionViewCell {
    fileprivate let singleModeService: SingleModeService = serviceLocator.get(SingleModeService.self)

    @IBOutlet weak var titleLabel: UILabel!

    fileprivate var level: Level!

    fileprivate var gradientLayer: CAGradientLayer?

    fileprivate let CORNER_RADIUS_COEFF: CGFloat = 0.25

    fileprivate func initStyle() {
        titleLabel.textColor = Color.Text

        layer.cornerRadius = self.bounds.size.width * CORNER_RADIUS_COEFF

        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        gradientLayer?.removeFromSuperlayer()

        backgroundColor = UIColor.clear
    }

    func updateLevel(_ level: Level) {
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

    fileprivate func setClearedState() {
        titleLabel.text = String(level.id)

        let gradient = Gradient.getLevelGradientByDifficulty(level.clearedDifficulty!)
        gradientLayer = addDiagonalGradient(gradient)
    }

    fileprivate func setAvailableState() {
        titleLabel.text = String(level.id)

        gradientLayer = addDiagonalGradient(Gradient.Ciphered)
    }

    fileprivate func setIgnoredState() {
        titleLabel.text = Emoji.LOCK

        gradientLayer = addDiagonalGradient(Gradient.Ignored)
        //layer.backgroundColor = Color.Ignore.CGColor
    }
}
