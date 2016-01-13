//
//  TutorialMessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

enum TutorialStage: Int {
    case Never = 1, Started, DecipherGuess, DecipherCloseTry, DecipherCloseTryHint, DecipherHint, DecipherRest, Deciphered, Skipped, Finished
}

var currentTutorialStage: TutorialStage = .Never

class TutorialMessagesViewController: MessagesViewController {
    let TUTORIAL_MESSAGE = "Welcome to the chat! I am glad to see you here. Have a good time!"

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        switch currentTutorialStage {
        case .Never:
            WTFTwoButtonsAlert.show("Tutorial",
                message: "Hi! It is your first time, do you want to see a tutorial?",
                firstButtonTitle: "Skip",
                secondButtonTitle: "Yes",
                viewPresenter: self,
                alertButtonAction: { () -> Void in
                    currentTutorialStage = .Skipped
                },
                cancelButtonAction: { () -> Void in
                    self.beginTutorial()
            })
        case .Deciphered:
            WTFOneButtonAlert.show("",
                message: "So far so good! Let's try to send a message. Type any text you want and press 'Send' button",
                firstButtonTitle: "Ok",
                viewPresenter: self)
        default: return
        }
    }
    
    override func sendButtonPressed(sender: AnyObject) {
        if (currentTutorialStage == .Started) {
            WTFOneButtonAlert.show("Tutorial",
                message: "Please, tap on a blue bubble with question marks to decipher it!",
                firstButtonTitle: "Ok",
                viewPresenter: self)
        } else {
            self.performSegueWithIdentifier("showMessagePreview", sender: messageText.text)
        }
    }
    
    private func beginTutorial() {
        currentTutorialStage = .Started
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
