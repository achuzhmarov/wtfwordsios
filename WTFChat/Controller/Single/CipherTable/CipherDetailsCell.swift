import Foundation

class CipherDetailsCell: UITableViewCell {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!
    @IBOutlet weak var difficultySelector: UISegmentedControl!

    private let cipherDifficulties = CipherDifficulty.getAll()

    private var selectedDifficulty = CipherDifficulty.Easy
    private var cipherType = CipherType.RightCutter

    func initStyle() {
        self.selectionStyle = .None;
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        updateLvlCollectionView()
    }

    func updateCipherType(cipherType: CipherType) {
        initStyle()

        self.cipherType = cipherType

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView
        updateLvlCollectionView()
    }

    private func updateLvlCollectionView() {
        let category = singleModeCategoryService.getCategory(cipherType)!
        lvlCollectionView.updateCategory(category)
    }
}
