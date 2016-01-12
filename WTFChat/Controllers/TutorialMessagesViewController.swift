//
//  TutorialMessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class TutorialMessagesViewController: MessagesViewController {
    let TUTORIAL_MESSAGE = "Welcome to the chat! I am glad to see you here. Have a good time!"
    
    var isTutorialMode = false
    var isTutorialFinished = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!isTutorialMode && !isTutorialFinished) {
            WTFTwoButtonsAlert.show("Tutorial",
                message: "Hi! It is your first time, do you want to see a tutorial?",
                firstButtonTitle: "Skip",
                secondButtonTitle: "Yes",
                viewPresenter: self,
                alertButtonAction: nil,
                cancelButtonAction: { () -> Void in
                    self.beginTutorial()
            })
        }
    }
    
    private func beginTutorial() {
        isTutorialMode = true
        setTutorialTalk()
        
        WTFOneButtonAlert.show("New message",
            message: "You have just recieved your first message. Tap on it to decipher!",
            firstButtonTitle: "Ok",
            viewPresenter: self)
        
        self.title = "Tutorial"
    }
    
    private func setTutorialTalk() {
        //add singleModeTalk
        let tutorialTalk = Talk(id: "00")
        tutorialTalk.isSingleMode = true
        let tutorialUser = User(login: "Tutorial", suggestions: 0)
        tutorialTalk.users.append(tutorialUser.login)
        tutorialTalk.users.append("")
        
        //load tutorial message
        let message = messageCipher.createMessage(TUTORIAL_MESSAGE, cipherType: CipherType.HalfWordRoundDown)
        messageCipher.addNewMessageToTalk(message, talk: tutorialTalk)
        
        talkService.addNewTalk(tutorialTalk)
        
        self.talk = tutorialTalk
        
        self.updateView()
    }
}
