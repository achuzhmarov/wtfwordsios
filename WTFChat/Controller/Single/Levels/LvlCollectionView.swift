import Foundation

protocol LevelSelectedComputer {
    func levelSelected(level: Level)
}

class LvlCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate { //UICollectionViewDelegateFlowLayout {
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
}
