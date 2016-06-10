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

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == HEADER_ROW) {
            return tableView.rowHeight
        } else {
            return CGFloat(LVLS_ROW_HEIGHT)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == HEADER_ROW) {
            let cell = dequeueReusableCellWithIdentifier(HEADER_CELL_ID, forIndexPath: indexPath) as! CipherHeaderCell

            let cipherType = cipherTypes[indexPath.section]
            cell.updateCipherType(cipherType)

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(DETAILS_CELL_ID, forIndexPath: indexPath) as! CipherDetailsCell

            let cipherType = cipherTypes[indexPath.section]
            cell.updateCipherType(cipherType)

            return cell
        }
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
