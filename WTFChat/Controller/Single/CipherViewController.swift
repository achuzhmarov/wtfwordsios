import Foundation

protocol CipherViewAppearedNotifier {
    func cipherViewAppeared(viewController: CipherViewController)
}

class CipherViewController: UIViewController, LevelSelectedComputer {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)

    @IBOutlet weak var easyStarImage: StarImage!
    @IBOutlet weak var normalStarImage: StarImage!
    @IBOutlet weak var hardStarImage: StarImage!
    @IBOutlet weak var cipherText: UILabel!

    @IBOutlet weak var lvlCollectionView: LvlCollectionView!

    var activeCipherIndex = 0
    var cipherViewAppearedNotifier: CipherViewAppearedNotifier?

    private let DECIPHER_SEGUE_ID = "showDecipher"
    private let LVL_CELL_SPACING: CGFloat = 10.0
    private let LVL_CELL_SIZE: CGFloat = 45.0
    private let LVL_VIEW_WIDTH_PADDING: CGFloat = 8.0 * 2
    private let VERTICAL_PADDING: CGFloat = 8.0 * 2

    private let cipherTypes = CipherType.getAll()
    private var selectedLevel: Level?

    override func viewDidLoad() {
        super.viewDidLoad()

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView
        lvlCollectionView.levelSelectedComputer = self

        reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        cipherViewAppearedNotifier?.cipherViewAppeared(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIHelper.clearBackButton(navigationItem)

        if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destinationViewController as! SingleDecipherViewController
            targetController.level = selectedLevel
        }
    }

    private func reloadData() {
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
                self.performSegueWithIdentifier(DECIPHER_SEGUE_ID, sender: self)
            } else {
                WTFOneButtonAlert.show("Not available yet",
                        message: "This level is not available yet. Please, wait for the next release!",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)

                return
            }
        }
    }

    func getFullHeight() -> CGFloat {
        let lvlCollectionHeight = getCollectionViewHeight()
        return lvlCollectionHeight + VERTICAL_PADDING + easyStarImage.bounds.height
    }

    private func getCollectionViewHeight() -> CGFloat {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(LVL_CELL_SIZE, LVL_CELL_SIZE)

        // Set left and right margins
        flowLayout.minimumInteritemSpacing = LVL_CELL_SPACING

        // Set top and bottom margins
        flowLayout.minimumLineSpacing = LVL_CELL_SPACING

        let size = CGSize(
            width: view.bounds.width - LVL_VIEW_WIDTH_PADDING,
            height: view.bounds.height
        )

        let frame = CGRect(
            origin: view.bounds.origin,
            size: size
        )

        let sizingLvlCollectionView = LvlCollectionView(frame: frame, collectionViewLayout: flowLayout)

        let category = getCurrentCategory()
        sizingLvlCollectionView.updateCategory(category)
        sizingLvlCollectionView.dataSource = lvlCollectionView

        let collectionViewSize = sizingLvlCollectionView.collectionViewLayout.collectionViewContentSize()

        return collectionViewSize.height
    }

    private func getCurrentCategory() -> SingleModeCategory {
        let cipherType = cipherTypes[activeCipherIndex]
        return singleModeCategoryService.getCategory(cipherType)!
    }
}
