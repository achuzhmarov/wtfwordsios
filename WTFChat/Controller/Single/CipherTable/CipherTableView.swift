import Foundation

class CipherTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    private let singleModeCategoryService: SingleModeCategoryService = serviceLocator.get(SingleModeCategoryService)

    private let HEADER_CELL_ID = "CipherHeaderCell"
    private let DETAILS_CELL_ID = "CipherDetailsCell"

    private let HEADER_ROW = 0
    private let LVLS_ROW_HEIGHT = 300

    private let cipherTypes = CipherType.getAll()
    private var cipherDifficulty = CipherDifficulty.Easy

    private var selectedType = CipherType.RightCutter

    private var openedSections: [Int: Bool] = [
            0: true,
            1: false,
            2: false,
            3: false,
            4: false
    ]

    var levelSelectedComputer: LevelSelectedComputer?

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cipherTypes.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (openedSections[section]!) { //if (cipherTypes[section] == selectedType) {
            return 2
        } else {
            return 1
        }
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == HEADER_ROW) {
            return tableView.rowHeight
        } else {
            let cellSpacing: CGFloat = 10.0
            let cellSize: CGFloat = 45.0
            let widthPadding: CGFloat = 8.0 * 2

            let lvlCollectionHeight = getCollectionViewHeight(tableView, indexPath: indexPath,
                    cellSpacing: cellSpacing, cellSize: cellSize, widthPadding: widthPadding)

            let verticalPadding: CGFloat = 8.0

            return lvlCollectionHeight + verticalPadding
        }
    }

    private func getCollectionViewHeight(tableView: UITableView, indexPath: NSIndexPath,
                                    cellSpacing: CGFloat, cellSize: CGFloat, widthPadding: CGFloat) -> CGFloat {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(cellSize, cellSize)

        // Set left and right margins
        flowLayout.minimumInteritemSpacing = cellSpacing

        // Set top and bottom margins
        flowLayout.minimumLineSpacing = cellSpacing

        let size = CGSize(
            width: tableView.bounds.width - widthPadding,
            height: tableView.bounds.height
        )

        let frame = CGRect(
            origin: tableView.bounds.origin,
            size: size
        )

        let lvlCollectionView = LvlCollectionView(frame: frame, collectionViewLayout: flowLayout)

        let cipherType = cipherTypes[indexPath.section]
        let category = singleModeCategoryService.getCategory(cipherType)!
        lvlCollectionView.updateCategory(category)
        lvlCollectionView.dataSource = lvlCollectionView

        let collectionViewSize = lvlCollectionView.collectionViewLayout.collectionViewContentSize()

        return collectionViewSize.height
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == HEADER_ROW) {
            return createCipherHeaderCell(indexPath)
        } else {
            let cell = createCipherDetailsCell(indexPath)
            return cell
        }
    }

    private func createCipherHeaderCell(indexPath: NSIndexPath) -> CipherHeaderCell  {
        let cell = dequeueReusableCellWithIdentifier(HEADER_CELL_ID, forIndexPath: indexPath) as! CipherHeaderCell

        let cipherType = cipherTypes[indexPath.section]
        cell.updateCipherType(cipherType)

        return cell
    }

    private func createCipherDetailsCell(indexPath: NSIndexPath) -> CipherDetailsCell  {
        let cell = dequeueReusableCellWithIdentifier(DETAILS_CELL_ID, forIndexPath: indexPath) as! CipherDetailsCell

        let cipherType = cipherTypes[indexPath.section]
        cell.updateCipherType(cipherType)
        cell.setLevelSelectedComputer(levelSelectedComputer)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == HEADER_ROW) {
            let section = indexPath.section
            openedSections[section] = !openedSections[section]!

            reloadSections(NSIndexSet(index: section), withRowAnimation: .Fade)

            if (openedSections[section]!) {
                let newRowPath = NSIndexPath(forItem: indexPath.row + 1, inSection: section)
                tableView.scrollToRowAtIndexPath(newRowPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }

    func updateCipherDifficulty(cipherDifficulty: CipherDifficulty) {
        self.cipherDifficulty = cipherDifficulty
        reloadData()
    }
}
