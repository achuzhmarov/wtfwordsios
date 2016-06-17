import Foundation

class LvlCell: UICollectionViewCell {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    @IBOutlet weak var titleLabel: UILabel!

    private var level: Level!

    private var gradientLayer: CAGradientLayer?

    private func initStyle() {
        titleLabel.textColor = Color.Text

        layer.cornerRadius = 12.0

        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        gradientLayer?.removeFromSuperlayer()
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
        gradientLayer = addGradient(gradient)
    }

    private func setAvailableState() {
        titleLabel.text = String(level.id)

        gradientLayer = addGradient(Gradient.CipheredGrad)
    }

    private func setIgnoredState() {
        titleLabel.text = Emoji.LOCK
        layer.backgroundColor = Color.Ignore.CGColor
    }
}
