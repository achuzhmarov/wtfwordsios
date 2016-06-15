import Foundation

class CipherTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    private let HEADER_CELL_ID = "CipherHeaderCell"
    private let DETAILS_CELL_ID = "CipherDetailsCell"

    private let HEADER_ROW = 0
    private let LVLS_ROW_HEIGHT = 300

    private let cipherTypes = CipherType.getAll()
    private var cipherDifficulty = CipherDifficulty.Easy

    private var selectedType = CipherType.RightCutter

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cipherTypes.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (cipherTypes[section] == selectedType) {
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

            let difficultySelectorHeight: CGFloat = 28.0
            let verticalPadding: CGFloat = 8.0 * 2

            return lvlCollectionHeight + difficultySelectorHeight + verticalPadding
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
        let singleTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: .Hard)!
        lvlCollectionView.updateSingleTalk(singleTalk)
        lvlCollectionView.dataSource = lvlCollectionView

        let collectionViewSize = lvlCollectionView.collectionViewLayout.collectionViewContentSize()

        return collectionViewSize.height
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == HEADER_ROW) {
            return createCipherHeaderCell(indexPath)
        } else {
            let cell = createCipherDetailsCell(indexPath)
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
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

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == HEADER_ROW) {
            selectedType = cipherTypes[indexPath.section]

            reloadData()
            //reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
        }
    }

    func updateCipherDifficulty(cipherDifficulty: CipherDifficulty) {
        self.cipherDifficulty = cipherDifficulty
        reloadData()
    }

    func getSelectedCipherType() -> CipherType? {
        if let index: NSIndexPath = indexPathForSelectedRow {
            return cipherTypes[index.row]
        }

        return nil
    }
}
