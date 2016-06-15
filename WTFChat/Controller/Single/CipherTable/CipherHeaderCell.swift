import UIKit

class CipherHeaderCell: UITableViewCell {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)

    @IBOutlet weak var starImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    func initStyle() {
        self.selectionStyle = .None;
    }

    func updateCipherType(cipherType: CipherType) {
        initStyle()

        cipherText.text = cipherType.description

        //let category = singleModeCategoryService.getSingleTalk(cipherType)

        /*let easyTalk = singleModeCategoryService.getSingleTalk(cipherType, cipherDifficulty: .Easy)!
        let normalTalk = singleModeCategoryService.getSingleTalk(cipherType, cipherDifficulty: .Normal)!
        let hardTalk = singleModeCategoryService.getSingleTalk(cipherType, cipherDifficulty: .Hard)!

        starImage.updateStarImage(easyTalk.wins, max: easyTalk.cipherSettings!.maxStars)*/
    }
}
