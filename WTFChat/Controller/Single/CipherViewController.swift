import Foundation

protocol CipherViewAppearedNotifier {
    func cipherViewAppeared(_ viewController: CipherViewController)
}

class CipherViewController: UIViewController, LevelSelectedComputer {
    fileprivate let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    fileprivate let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    fileprivate let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    fileprivate let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    @IBOutlet weak var easyStarImage: StarImage!
    @IBOutlet weak var normalStarImage: StarImage!
    @IBOutlet weak var hardStarImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!

    var activeCipherIndex = 0
    var cipherViewAppearedNotifier: CipherViewAppearedNotifier?

    fileprivate let LEVEL_PREVIEW_SEGUE_ID = "showLevelPreview"
    fileprivate let DECIPHER_SEGUE_ID = "showDecipher"
    fileprivate let LVL_CELL_SPACING: CGFloat = 10.0
    fileprivate let LVL_VIEW_WIDTH_PADDING: CGFloat = 8.0 * 2
    fileprivate let VERTICAL_PADDING: CGFloat = 20 + 16

    fileprivate let cipherTypes = CipherType.getAll()
    fileprivate var selectedLevel: Level?
    fileprivate var messageForDecipher: Message?

    override func viewDidLoad() {
        super.viewDidLoad()

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView
        lvlCollectionView.levelSelectedComputer = self

        reloadData()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        reloadData()

        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
        cipherViewAppearedNotifier?.cipherViewAppeared(self)
        guiDataService.updateLastSelectedCategoryType(getCurrentCategory().cipherType)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LEVEL_PREVIEW_SEGUE_ID {
            let targetController = segue.destination as! LevelPreviewViewController
            targetController.level = selectedLevel
        }
    }

    func reloadData() {
        let category = getCurrentCategory()
        cipherText.text = category.cipherType.description

        easyStarImage.updateStarImage(.easy, progress: category.getProgress(.easy))
        normalStarImage.updateStarImage(.normal, progress: category.getProgress(.normal))
        hardStarImage.updateStarImage(.hard, progress: category.getProgress(.hard))

        lvlCollectionView.updateCategory(category)
    }

    func levelSelected(_ level: Level) {
        if (singleModeService.isLevelAvailable(level)) {
            if (singleMessageService.hasTextCategoryForLevel(level)) {
                selectedLevel = level
                self.performSegue(withIdentifier: LEVEL_PREVIEW_SEGUE_ID, sender: self)
            } else {
                //do nothing
            }
        }
    }

    func getFullHeight() -> CGFloat {
        lvlCollectionView.reloadData()

        let collectionViewSize = lvlCollectionView.collectionViewLayout.collectionViewContentSize
        let lvlCollectionHeight = collectionViewSize.height

        return lvlCollectionHeight + VERTICAL_PADDING + easyStarImage.bounds.height
    }

    func getCurrentCategory() -> SingleModeCategory {
        let cipherType = cipherTypes[activeCipherIndex]
        return singleModeCategoryService.getCategory(cipherType)!
    }

    @IBAction func backToNextLevel(_ segue:UIStoryboardSegue) {

    }
}
