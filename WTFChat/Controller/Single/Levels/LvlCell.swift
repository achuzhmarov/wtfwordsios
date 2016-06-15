import Foundation

class LvlCell: UICollectionViewCell {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    @IBOutlet weak var titleLabel: UILabel!

    private func initStyle() {
        titleLabel.textColor = Color.FONT

        layer.cornerRadius = 12.0

        //layer.borderWidth = 1
        //layer.borderColor = UIColor.blackColor().CGColor
    }

    func updateLevel(level: Level) {
        initStyle()

        titleLabel.text = String(level.id)

        if (level.cleared) {
            layer.backgroundColor = Color.SUCCESS.CGColor
        } else if singleModeService.isLevelAvailable(level) {
            layer.backgroundColor = Color.CIPHERED.CGColor
        } else {
            layer.backgroundColor = Color.IGNORE.CGColor
            titleLabel.text = Emoji.LOCK
        }
    }
}
