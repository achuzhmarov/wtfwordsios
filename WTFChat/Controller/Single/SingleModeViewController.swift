//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewController: UITableViewController {
    private let TUTORIAL_SECTION = 0
    private let HEADER_ROW = 0
    private let HEADER_ROW_HEIGHT = CGFloat(30)

    private let cipherTypes = CipherType.getAll()
    private let cipherDifficulties = CipherDifficulty.getAll()

    private let cipherService: CipherService = serviceLocator.get(CipherService)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //one section for every difficulty + tutorial section
        return cipherDifficulties.count + 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == TUTORIAL_SECTION) {
            return tableView.rowHeight
        } else if (indexPath.row == HEADER_ROW) {
            return HEADER_ROW_HEIGHT
        } else {
            return tableView.rowHeight
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == TUTORIAL_SECTION) {
            return 1
        } else {
            //one row for every cipher type + header
            return cipherTypes.count + 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == TUTORIAL_SECTION) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TutorialCell", forIndexPath: indexPath) as! TutorialCell

            cell.updateTitle("Tutorial")

            return cell
        } else if (indexPath.row == HEADER_ROW) {
            let cell = tableView.dequeueReusableCellWithIdentifier("DifficultyCell", forIndexPath: indexPath) as! DifficultyCell

            let difficulty = cipherDifficulties[indexPath.section - 1]
            cell.updateDifficulty(difficulty)

            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CipherCell", forIndexPath: indexPath) as! CipherCell

            let cipherType = cipherTypes[indexPath.row - 1]
            let cipherDifficulty = cipherDifficulties[indexPath.section - 1]

            let cipherData = cipherService.getCipherData(cipherType, difficulty: cipherDifficulty)
            cell.updateCipher(cipherData!)

            return cell
        }
    }
}
