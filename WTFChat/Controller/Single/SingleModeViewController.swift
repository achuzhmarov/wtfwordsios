//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewController: UIViewController {
    private let singleTalkService: SingleTalkService = serviceLocator.get(SingleTalkService)

    @IBOutlet weak var cipherTableView: CipherTableView!
    @IBOutlet weak var difficultySelector: UISegmentedControl!

    private let cipherDifficulties = CipherDifficulty.getAll()
    private var selectedDifficulty = CipherDifficulty.Easy

    private var cipherTalks: [SingleTalk]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        cipherTableView.delegate = self.cipherTableView
        cipherTableView.dataSource = self.cipherTableView

        /*let tryButton = UIBarButtonItem(title: "Try it",
                style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SendMessageViewController.tryTapped(_:)))*/

        //let heartsText = Emoji.FULL_HEART + Emoji.FULL_HEART + Emoji.FULL_HEART
        /*let heartsText = Emoji.FULL_HEART

        let heartButton = UIBarButtonItem(title: heartsText,
            style: UIBarButtonItemStyle.Plain, target: self, action: nil)

        navigationItem.rightBarButtonItem = heartButton*/
        //self.tabBarController?.tabBar.items![0].title = ""
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cipherTableView.reloadData()
    }

    @IBAction func difficultyChanged(sender: AnyObject) {
        selectedDifficulty = cipherDifficulties[difficultySelector.selectedSegmentIndex]
        cipherTableView.updateCipherDifficulty(selectedDifficulty)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        UIHelper.clearBackButton(navigationItem)

        if segue.identifier == "showMessages" {
            let targetController = segue.destinationViewController as! SingleMessageViewController

            if let cipherType = cipherTableView.getSelectedCipherType() {
                let singleTalk = singleTalkService.getSingleTalk(cipherType, cipherDifficulty: selectedDifficulty)
                targetController.talk = singleTalk!
            }
        }
    }
}
