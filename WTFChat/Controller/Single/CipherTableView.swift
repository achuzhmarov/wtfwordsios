import Foundation

class CipherTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    private let cipherTypes = CipherType.getAll()
    private var cipherDifficulty = CipherDifficulty.Easy

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cipherTypes.count
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = dequeueReusableCellWithIdentifier("CipherCell", forIndexPath: indexPath) as! CipherCell

        let cipherType = cipherTypes[indexPath.row]

        let singleTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: cipherDifficulty)
        cell.updateSingleTalk(singleTalk!)

        return cell
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
