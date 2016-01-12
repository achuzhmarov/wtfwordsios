//
//  TutorialMessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class TutorialMessagesViewController: MessagesViewController {
    var isTutorial = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        WTFTwoButtonsAlert.show("Tutorial",
            message: "Hi! It is your first time, do you want to see a tutorial?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.isTutorial = true
        }
    }
}
