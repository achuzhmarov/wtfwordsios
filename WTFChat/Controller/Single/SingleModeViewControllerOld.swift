//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewControllerOld: UIViewController, LevelSelectedComputer {
    private let singleModeService: SingleModeService = serviceLocator.get(SingleModeService)
    private let singleMessageService: SingleMessageService = serviceLocator.get(SingleMessageService)

    private let DECIPHER_SEGUE_ID = "showDecipher"

    @IBOutlet weak var cipherTableView: CipherTableView!

    private var selectedLevel: Level?

    var activeCipherIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        cipherTableView.delegate = cipherTableView
        cipherTableView.dataSource = cipherTableView
        cipherTableView.rowHeight = UITableViewAutomaticDimension
        cipherTableView.levelSelectedComputer = self

        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = .Left
        self.view.addGestureRecognizer(swipeLeft)

        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = .Right
        self.view.addGestureRecognizer(swipeRight)

        cipherTableView.activeCipherIndex = activeCipherIndex
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

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Right:
                    cipherTableView.swipeRight()
                case UISwipeGestureRecognizerDirection.Left:
                    cipherTableView.swipeLeft()
                default:
                    break
                }
        }
    }

    func levelSelected(level: Level) {
        if (singleModeService.isLevelAvailable(level)) {
            if (singleMessageService.hasTextCategoryForLevel(level)) {
                selectedLevel = level
                self.performSegueWithIdentifier(DECIPHER_SEGUE_ID, sender: self)
            } else {
                WTFOneButtonAlert.show("Not available yet",
                        message: "This level is not available yet. Please, wait for the next release!",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)

                return
            }
        }
    }
}
