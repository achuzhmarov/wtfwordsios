//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewController: UIViewController, LevelSelectedComputer {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)

    private let DECIPHER_SEGUE_ID = "showDecipher"

    @IBOutlet weak var cipherTableView: CipherTableView!

    private var selectedLevel: Level?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        cipherTableView.delegate = cipherTableView
        cipherTableView.dataSource = cipherTableView
        cipherTableView.rowHeight = UITableViewAutomaticDimension
        cipherTableView.levelSelectedComputer = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cipherTableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIHelper.clearBackButton(navigationItem)

        if segue.identifier == DECIPHER_SEGUE_ID {
            let targetController = segue.destinationViewController as! SingleDecipherViewController
            targetController.level = selectedLevel
        }
    }

    func levelSelected(level: Level) {
        if (singleModeService.isLevelAvailable(level)) {
            selectedLevel = level
            self.performSegueWithIdentifier(DECIPHER_SEGUE_ID, sender: self)
        }
    }
}
