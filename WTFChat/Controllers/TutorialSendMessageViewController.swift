//
//  TutorialSendMessageViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class TutorialSendMessageViewController: SendMessageViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (currentTutorialStage == .SendMessage) {
            WTFOneButtonAlert.show("Choose a cipher",
                message: "You can now choose a cipher type and a difficulty to cipher your message. Try different ones and see how your message transforms. Make a choice and press 'Send' button at the top right corner",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    currentTutorialStage = .SelectCipher
            }
        }
    }
    
    override func sendTapped(sender: AnyObject) {
        if (currentTutorialStage == .SelectCipher) {
            currentTutorialStage = .MessageSended
        }
        
        super.sendTapped(sender)
    }
}