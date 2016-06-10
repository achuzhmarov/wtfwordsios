import Foundation

class LvlCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate { //UICollectionViewDelegateFlowLayout {
    var singleTalk: SingleTalk!

    func updateSingleTalk(singleTalk: SingleTalk) {
        self.singleTalk = singleTalk
        reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singleTalk.cipherSettings!.maxStars
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LvlCell", forIndexPath: indexPath) as! LvlCell

        cell.updateLvl(indexPath.item)
        return cell
    }
}
