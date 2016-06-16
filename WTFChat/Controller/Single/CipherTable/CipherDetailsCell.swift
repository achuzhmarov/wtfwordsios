import Foundation

class CipherDetailsCell: UITableViewCell {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!

    private var cipherType = CipherType.RightCutter

    func initStyle() {
        self.selectionStyle = .None;
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

    func setLevelSelectedComputer(levelSelectedComputer: LevelSelectedComputer?) {
        lvlCollectionView.levelSelectedComputer = levelSelectedComputer
    }
}
