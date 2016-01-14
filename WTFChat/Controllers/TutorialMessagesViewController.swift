//
//  TutorialMessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import UIKit

enum TutorialStage: Int {
    case Never = 0, Started, DecipherGuess, DecipherCloseTry, DecipherCloseTryHint, DecipherHint, DecipherRest, Deciphered, SendMessage, SelectCipher, MessageSended, ResponseAquired, DetailsViewed, Skipped, Finished
}

var currentTutorialStage: TutorialStage = .Never

class TutorialMessagesViewController: MessagesViewController {
    let TUTORIAL_MESSAGE_MAIN = "Welcome to the chat! I am glad to see you here. Have a good time!"
    let TUTORIAL_TIP1 = "So, I see you are interested. Let's me give you some more advices about leveling up!"
    let TUTORIAL_TIP2 = "You will get less XP for an orange word if you open it by tap. But you will still get X3 bonus XP for fully deciphered message."
    let TUTORIAL_TIP3 = "There is daily XP limit for chatting with the same friend. If you start to gain small amount of XP, try to chat with someone else."
    let TUTORIAL_TIP4 = "You will get the same XP amount for different ciphers. Only it's difficulty matter"
    let TUTORIAL_TIP5 = "You can get significally more XP when deciphering Hard messages. But it isn't simple, you see!"
    
    let TUTORIAL_STAGE_PROPERTY_KEY = "tutorialStage"
    let nsUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //if it is first init, look for saved stage value
        if (currentTutorialStage == .Never) {
            let savedTutorialStage = nsUserDefaults.integerForKey(TUTORIAL_STAGE_PROPERTY_KEY)
            currentTutorialStage = TutorialStage(rawValue: savedTutorialStage)!
        }
        
        switch currentTutorialStage {
        case .Never:
            WTFTwoButtonsAlert.show("Tutorial",
                message: "Hi! It is your first time, do you want to see a tutorial?",
                firstButtonTitle: "Skip",
                secondButtonTitle: "Yes",
                viewPresenter: self,
                alertButtonAction: { () -> Void in
                    currentTutorialStage = .Skipped
                    self.nsUserDefaults.setInteger(currentTutorialStage.rawValue,
                        forKey: self.TUTORIAL_STAGE_PROPERTY_KEY)
                },
                cancelButtonAction: { () -> Void in
                    self.beginTutorial()
            })
        case .Deciphered:
            WTFOneButtonAlert.show("",
                message: "So far so good! Let's try to send a message. Type any text you want and press 'Send' button",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    currentTutorialStage = .SendMessage
            }
        case .SelectCipher:
            WTFOneButtonAlert.show("",
                message: "You have not sent your message. Please, tap 'Send' button. After you selected a cipher, please, tap 'Send' again on a Preview screen",
                firstButtonTitle: "Ok",
                viewPresenter: self)
        case .MessageSended:
            WTFOneButtonAlert.show("",
                message: "Yay! You have successfully send your first message! You see? Wait a sec, i'll soon decipher it",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    sleep(1)
                    self.decipherSendedMessage()
                    
                    WTFOneButtonAlert.show("",
                        message: "See? It was fast. In a real talk you will have to wait some more before your friend decipher it. As you see, I had some difficulties with deciphering. Please, tap on a message to view details.",
                        firstButtonTitle: "Ok",
                        viewPresenter: self) { () -> Void in
                            currentTutorialStage = .ResponseAquired
                    }
            }
        case .DetailsViewed:
            WTFOneButtonAlert.show("Finish",
                message: "Yahooo! You have finished the tutorial! I'll give you some more messages to practice. But feel free to ignore it. Now you can play with someone in local mode (Pass and play) or SignUp for an online account to chat with people all over the world! Exciting, isn't it?",
                firstButtonTitle: "Ok",
                viewPresenter: self) { () -> Void in
                    currentTutorialStage = .Finished
                    self.endTutorial()
            }
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
    
    override func sendMessage(segue:UIStoryboardSegue) {
        if (currentTutorialStage == .MessageSended) {
            if let sendMessageController = segue.sourceViewController as? SendMessageViewController {
                self.cipherType = sendMessageController.cipherType
                self.lastSendedMessage = sendMessageController.message
                let newMessage = messageCipher.addNewMessageToTalk(self.lastSendedMessage!, talk: self.talk!)
                newMessage.author = userService.getUserLogin()
                
                talkService.updateTalkInArray(self.talk, withMessages: true)
                
                self.updateView(true)
            }
        } else {
            super.sendMessage(segue)
        }
    }
    
    private func beginTutorial() {
        currentTutorialStage = .Started
        
        let noviceUser = User(login: "Novice", suggestions: 4)
        noviceUser.buyNonConsum.append(IAPProducts.getProductRef(IAPProducts.CIPHER_ALL)!)
        userService.setTutorialUser(noviceUser)
        
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
        //tutorialTalk.isSingleMode = true
        let tutorialUser = User(login: "Tutorial", suggestions: 0)
        tutorialTalk.users.append(tutorialUser.login)
        tutorialTalk.users.append("")
        
        //load tutorial message
        var message = messageCipher.createMessage(TUTORIAL_MESSAGE_MAIN, cipherType: CipherType.HalfWordRoundDown)
        message = messageCipher.addNewMessageToTalk(message, talk: tutorialTalk)
        message.author = tutorialUser.login
        
        talkService.addNewTalk(tutorialTalk)
        
        self.talk = tutorialTalk
        
        self.updateView()
    }
    
    private func endTutorial() {
        nsUserDefaults.setInteger(currentTutorialStage.rawValue, forKey: TUTORIAL_STAGE_PROPERTY_KEY)
        
        userService.clearTutorialUser()
        
        talkService.clearTalks()
        self.talk = talkService.getSingleModeTalk()
        
        var message = messageCipher.createMessage(TUTORIAL_TIP1, cipherType: CipherType.HalfWordRoundDownFromEnd)
        message = messageCipher.addNewMessageToTalk(message, talk: self.talk)
        CoreMessage.create(message)
        
        message = messageCipher.createMessage(TUTORIAL_TIP2, cipherType: CipherType.NormalDoubleCutter)
        message = messageCipher.addNewMessageToTalk(message, talk: self.talk)
        CoreMessage.create(message)
        
        message = messageCipher.createMessage(TUTORIAL_TIP3, cipherType: CipherType.NormalRandomCutter)
        message = messageCipher.addNewMessageToTalk(message, talk: self.talk)
        CoreMessage.create(message)
        
        message = messageCipher.createMessage(TUTORIAL_TIP4, cipherType: CipherType.ShuffleFullWord)
        message = messageCipher.addNewMessageToTalk(message, talk: self.talk)
        CoreMessage.create(message)
        
        message = messageCipher.createMessage(TUTORIAL_TIP5, cipherType: CipherType.FirstLetter)
        message = messageCipher.addNewMessageToTalk(message, talk: self.talk)
        CoreMessage.create(message)
        
        talkService.updateTalkInArray(self.talk, withMessages: true)
        
        self.title = talk.getFriendLogin().capitalizedString
        
        self.updateView()
    }
    
    private func decipherSendedMessage() {
        let message = talk.messages[talk.messages.count - 1]
        
        for i in 0..<message.words.count {
            let word = message.words[i]
            
            if (word.wordType == .New) {
                message.words[i].wordType = .Success
            }
        }
        
        for _ in 0...2 {
            let randomIndex = Int(arc4random_uniform(UInt32(message.words.count)))
            
            if (message.words[randomIndex].wordType == .Success) {
                message.words[randomIndex].wordType = .Failed
            }
        }
        
        message.deciphered = true
        
        talk.messages[talk.messages.count - 1] = message
        
        self.updateView()
    }
}
