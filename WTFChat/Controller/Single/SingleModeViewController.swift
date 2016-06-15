//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewController: UIViewController {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    @IBOutlet weak var cipherTableView: CipherTableView!

    private var selectedCipherType = CipherType.RightCutter

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        cipherTableView.delegate = cipherTableView
        cipherTableView.dataSource = cipherTableView
        cipherTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cipherTableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIHelper.clearBackButton(navigationItem)

        /*if segue.identifier == "selectCipher" {
            let targetController = segue.destinationViewController as! LvlSelectViewController

            if let cipherType = cipherTableView.getSelectedCipherType() {
                let singleTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: selectedDifficulty)
                targetController.talk = singleTalk!
            }
        }*/
    }
}
