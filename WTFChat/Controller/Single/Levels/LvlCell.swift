import Foundation

class LvlCell: UICollectionViewCell {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    @IBOutlet weak var titleLabel: UILabel!

    private func initStyle() {
        titleLabel.textColor = Color.Font

        layer.cornerRadius = 12.0

        //layer.borderWidth = 1
        //layer.borderColor = UIColor.blackColor().CGColor
    }

    func updateLevel(level: Level) {
        initStyle()

        titleLabel.text = String(level.id)

        if (level.cleared) {
            layer.backgroundColor = Color.Success.CGColor
        } else if singleModeService.isLevelAvailable(level) {
            layer.backgroundColor = Color.Ciphered.CGColor
        } else {
            layer.backgroundColor = Color.Ignore.CGColor
            titleLabel.text = Emoji.LOCK
        }
    }
}
