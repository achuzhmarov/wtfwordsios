import Foundation

protocol LevelSelectedComputer {
    func levelSelected(_ level: Level)
}

class LvlCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate { //UICollectionViewDelegateFlowLayout {
    let LVL_CELL_SPACING: CGFloat = 10.0

    var category: SingleModeCategory!

    var levelSelectedComputer: LevelSelectedComputer?

    func updateCategory(_ category: SingleModeCategory) {
        self.backgroundColor = UIColor.clear

        self.category = category
        reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.levels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LvlCell", for: indexPath) as! LvlCell

        cell.updateLevel(category.levels[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        levelSelectedComputer?.levelSelected(category.levels[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
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

    func getCellWidth(_ cellsPerRow: Int) -> CGFloat {
        return CGFloat((bounds.width - CGFloat(cellsPerRow - 1) * LVL_CELL_SPACING) / CGFloat(cellsPerRow))
    }
}
