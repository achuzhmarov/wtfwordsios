import UIKit

class CipherHeaderCell: UITableViewCell {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)

    @IBOutlet weak var easyStarImage: StarImage!
    @IBOutlet weak var normalStarImage: StarImage!
    @IBOutlet weak var hardStarImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    private func initStyle() {
        self.selectionStyle = .None;
    }

    func updateCipherType(cipherType: CipherType) {
        initStyle()

        cipherText.text = cipherType.description

        let category = singleModeCategoryService.getCategory(cipherType)!

        easyStarImage.updateStarImage(.Easy, progress: category.getProgress(.Easy))
        normalStarImage.updateStarImage(.Normal, progress: category.getProgress(.Normal))
        hardStarImage.updateStarImage(.Hard, progress: category.getProgress(.Hard))
    }
}
