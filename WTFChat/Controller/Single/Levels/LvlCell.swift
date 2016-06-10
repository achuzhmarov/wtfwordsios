import Foundation

class LvlCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    private func initStyle() {
        titleLabel.textColor = Color.FONT

        layer.cornerRadius = 12.0

        //layer.borderWidth = 1
        //layer.borderColor = UIColor.blackColor().CGColor
    }

    func updateLvl(index: Int) {
        initStyle()

        titleLabel.text = String(index + 1)

        if (index < 4) {
            layer.backgroundColor = Color.SUCCESS.CGColor
        } else if (index < 5) {
            layer.backgroundColor = Color.CIPHERED.CGColor
        } else {
            layer.backgroundColor = Color.IGNORE.CGColor
            titleLabel.text = Emoji.LOCK
        }
    }
}
