import Foundation

protocol CipherViewAppearedNotifier {
    func cipherViewAppeared(viewController: CipherViewController)
}

class CipherViewController: UIViewController, LevelSelectedComputer {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService)

    @IBOutlet weak var easyStarImage: StarImage!
    @IBOutlet weak var normalStarImage: StarImage!
    @IBOutlet weak var hardStarImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!

    var activeCipherIndex = 0
    var cipherViewAppearedNotifier: CipherViewAppearedNotifier?

    private let LEVEL_PREVIEW_SEGUE_ID = "showLevelPreview"
    private let DECIPHER_SEGUE_ID = "showDecipher"
    private let LVL_CELL_SPACING: CGFloat = 10.0
    private let LVL_VIEW_WIDTH_PADDING: CGFloat = 8.0 * 2
    private let VERTICAL_PADDING: CGFloat = 20 + 16

    private let cipherTypes = CipherType.getAll()
    private var selectedLevel: Level?
    private var messageForDecipher: Message?

    override func viewDidLoad() {
        super.viewDidLoad()

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView
        lvlCollectionView.levelSelectedComputer = self

        reloadData()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        reloadData()

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
        cipherViewAppearedNotifier?.cipherViewAppeared(self)
        guiDataService.updateLastSelectedCategoryType(getCurrentCategory().cipherType)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == LEVEL_PREVIEW_SEGUE_ID {
            let targetController = segue.destinationViewController as! LevelPreviewViewController
            targetController.level = selectedLevel
        }
    }

    func reloadData() {
        let category = getCurrentCategory()
        cipherText.text = category.cipherType.description

        easyStarImage.updateStarImage(.Easy, progress: category.getProgress(.Easy))
        normalStarImage.updateStarImage(.Normal, progress: category.getProgress(.Normal))
        hardStarImage.updateStarImage(.Hard, progress: category.getProgress(.Hard))

        lvlCollectionView.updateCategory(category)
    }

    func levelSelected(level: Level) {
        if (singleModeService.isLevelAvailable(level)) {
            if (singleMessageService.hasTextCategoryForLevel(level)) {
                selectedLevel = level
                self.performSegueWithIdentifier(LEVEL_PREVIEW_SEGUE_ID, sender: self)
            } else {
                WTFOneButtonAlert.show("Not available yet",
                        message: "This level is not available yet. Please, wait for the next release!",
                        firstButtonTitle: "Ok")

                return
            }
        }
    }

    func getFullHeight() -> CGFloat {
        lvlCollectionView.reloadData()

        let collectionViewSize = lvlCollectionView.collectionViewLayout.collectionViewContentSize()
        let lvlCollectionHeight = collectionViewSize.height

        return lvlCollectionHeight + VERTICAL_PADDING + easyStarImage.bounds.height
    }

    func getCurrentCategory() -> SingleModeCategory {
        let cipherType = cipherTypes[activeCipherIndex]
        return singleModeCategoryService.getCategory(cipherType)!
    }

    @IBAction func backToNextLevel(segue:UIStoryboardSegue) {

    }
}
