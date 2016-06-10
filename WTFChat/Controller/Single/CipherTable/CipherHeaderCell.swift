import UIKit

class CipherHeaderCell: UITableViewCell {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    @IBOutlet weak var starImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    func initStyle() {
        self.selectionStyle = .None;
    }

    func updateCipherType(cipherType: CipherType) {
        initStyle()

        cipherText.text = cipherType.description

        let easyTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: .Easy)!
        let normalTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: .Normal)!
        let hardTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: .Hard)!

        starImage.updateStarImage(easyTalk.wins, max: easyTalk.cipherSettings!.maxStars)
    }
}
