import Foundation

protocol LevelSelectedComputer {
    func levelSelected(level: Level)
}

class LvlCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate { //UICollectionViewDelegateFlowLayout {
    let LVL_CELL_SPACING: CGFloat = 10.0

    var category: SingleModeCategory!

    var levelSelectedComputer: LevelSelectedComputer?

    func updateCategory(category: SingleModeCategory) {
        self.backgroundColor = UIColor.clearColor()

        self.category = category
        reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.levels.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LvlCell", forIndexPath: indexPath) as! LvlCell

        cell.updateLevel(category.levels[indexPath.item])
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        levelSelectedComputer?.levelSelected(category.levels[indexPath.item])
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = getCellWidth()
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func getCellWidth() -> CGFloat {
        if (bounds.width > bounds.height) {
            return getCellWidth(8)
        } else {
            var result: CGFloat

            let CELLS_PER_ROW = 4
            result = getCellWidth(CELLS_PER_ROW)

            let cellsCount = category.levels.count
            let rowsCount = CGFloat(cellsCount / CELLS_PER_ROW)

            let height = result * rowsCount + (rowsCount - 1) * LVL_CELL_SPACING

            if height > bounds.height {
                result = getCellWidth(5)
            }

            return result
        }
    }

    func getCellWidth(cellsPerRow: Int) -> CGFloat {
        return CGFloat((bounds.width - CGFloat(cellsPerRow - 1) * LVL_CELL_SPACING) / CGFloat(cellsPerRow))
    }
}
