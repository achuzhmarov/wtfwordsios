import Foundation

class CipherDetailsCell: UITableViewCell {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!
    @IBOutlet weak var difficultySelector: UISegmentedControl!

    private let cipherDifficulties = CipherDifficulty.getAll()

    private var selectedDifficulty = CipherDifficulty.Easy
    private var cipherType = CipherType.RightCutter

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        updateLvlCollectionView()
    }

    func updateCipherType(cipherType: CipherType) {
        self.cipherType = cipherType

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView
        updateLvlCollectionView()
    }

    private func updateLvlCollectionView() {
        let singleTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: selectedDifficulty)!
        lvlCollectionView.updateSingleTalk(singleTalk)
    }
}
