import UIKit

enum TutorialStageOld: Int {
    case never = 0, started, decipherGuess, decipherCloseTry, decipherCloseTryHint, decipherHint, decipherRest, deciphered, sendMessage, selectCipher, messageSended, responseAquired, detailsViewed, skipped, finished
}

var currentTutorialStage: TutorialStageHardcore = .never

class TutorialMessagesViewControllerOld: MessagesViewController {
    fileprivate let talkService: TalkService = serviceLocator.get(TalkService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    fileprivate let coreMessageService: CoreMessageService = serviceLocator.get(CoreMessageService.self)

    fileprivate let TUTORIAL_MESSAGE_MAIN = "Welcome to the chat! I am glad to see you here. Have a good time!"
    fileprivate let TUTORIAL_TIP1 = "So, I see you are interested. Let me give you some more advice on leveling up!"
    fileprivate let TUTORIAL_TIP2 = "You will get less XP for an orange word if you open it with a tap. But you will still get X3 bonus XP for fully deciphered message."
    fileprivate let TUTORIAL_TIP3 = "There is a daily XP threshold for chatting with the same friend. If you start getting less XP, try to chat with someone else."
    fileprivate let TUTORIAL_TIP4 = "You will get the same XP amount for different ciphers. Only its difficulty matters."
    fileprivate let TUTORIAL_TIP5 = "You can get significantly more XP when deciphering Hard messages. But it isn't simple, you see!"

    fileprivate let TUTORIAL_STAGE_PROPERTY_KEY = "tutorialStage"
    fileprivate let nsUserDefaults = UserDefaults.standard

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //if it is first init, look for saved stage value
        if (currentTutorialStage == .never) {
            let savedTutorialStage = nsUserDefaults.integer(forKey: TUTORIAL_STAGE_PROPERTY_KEY)
            currentTutorialStage = TutorialStageHardcore(rawValue: savedTutorialStage)!
        }
        
        switch currentTutorialStage {
        case .never:
            WTFTwoButtonsAlert.show("Tutorial",
                message: "Hi! It is your first time, would you like to start a tutorial?",
                firstButtonTitle: "Start",
                secondButtonTitle: "Skip",
                alertButtonAction: { () -> Void in
                    self.beginTutorial()
                },
                cancelButtonAction: { () -> Void in
                    currentTutorialStage = .skipped
                    self.nsUserDefaults.set(currentTutorialStage.rawValue,
                        forKey: self.TUTORIAL_STAGE_PROPERTY_KEY)
            })
        case .deciphered:
            WTFOneButtonAlert.show("",
                message: "So far so good! Try to send a message. Type any text you want and press 'Send' button.",
                firstButtonTitle: "Ok") { () -> Void in
                    currentTutorialStage = .sendMessage
            }
        case .selectCipher:
            WTFOneButtonAlert.show("",
                message: "You have not sent your message. Please, tap 'Send' button. After you have selected a cipher, please, tap 'Send' again on the 'Preview' screen.",
                firstButtonTitle: "Ok")
        case .messageSended:
            WTFOneButtonAlert.show("",
                message: "Yay! You have successfully sent your first message! You see? Wait a sec, I will soon decipher it.",
                firstButtonTitle: "Ok") { () -> Void in
                    sleep(1)
                    self.decipherSendedMessage()
                    
                    WTFOneButtonAlert.show("",
                        message: "See? It was fast. In a real conversation you will have to wait some more before your friend decipher it. As you see, it is red! That means I had some difficulties deciphering it. Please, tap on a message to view details.",
                        firstButtonTitle: "Ok") { () -> Void in
                            currentTutorialStage = .responseAquired
                    }
            }
        case .detailsViewed:
            WTFOneButtonAlert.show("Finished",
                message: "Yahooo! You have finished the tutorial! I'll give you some more messages to practice. But feel free to ignore them. Now you can play with someone sitting next to you in 'Pass and play' mode or SignUp for an online account to chat with people all over the world! Exciting, isn't it?",
                firstButtonTitle: "Ok") { () -> Void in
                    currentTutorialStage = .finished
                    self.endTutorial()
            }
        default: return
        }
    }
    
    override func sendButtonPressed(_ sender: AnyObject) {
        if (currentTutorialStage == .started) {
            WTFOneButtonAlert.show("Tutorial",
                message: "Please, tap on a blue bubble with question marks to decipher it!",
                firstButtonTitle: "Ok")
        } else {
            self.performSegue(withIdentifier: "showMessagePreview", sender: messageText.text)
        }
    }
    
    override func sendMessage(_ segue:UIStoryboardSegue) {
        if (currentTutorialStage == .messageSended) {
            if let sendMessageController = segue.source as? SendMessageViewController {
                self.cipherType = sendMessageController.cipherType
                self.lastSendedMessage = sendMessageController.message
                let newMessage = messageCipherService.addNewMessageToTalk(self.lastSendedMessage!, talk: self.friendTalk!)
                newMessage.author = currentUserService.getUserLogin()
                
                talkService.updateTalkInArray(self.friendTalk, withMessages: true)

                updateViewAfterSend()
            }
        } else {
            super.sendMessage(segue)
        }
    }
    
    fileprivate func beginTutorial() {
        currentTutorialStage = .started
        
        //let noviceUser = User(login: "Novice", hints: 4)
        //currentUserService.setNewUser(noviceUser)
        
        setTutorialTalk()
        
        WTFOneButtonAlert.show("New message",
            message: "You have just recieved your first message. Tap on it to decipher!",
            firstButtonTitle: "Ok")
        
        self.title = "Tutorial"
    }
    
    fileprivate func setTutorialTalk() {
        //add singleModeTalk
        let tutorialTalk = FriendTalk(id: "00")
        //tutorialTalk.isSingleMode = true
        let tutorialUser = User(login: "Tutorial")
        tutorialTalk.users.append(tutorialUser.login)
        tutorialTalk.users.append("")
        
        //load tutorial message
        let message = messageCipherService.createMessage(TUTORIAL_MESSAGE_MAIN, cipherType: .rightCutter, cipherDifficulty: .normal)
        let remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: tutorialTalk)
        remoteMessage.author = tutorialUser.login
        
        talkService.addNewTalk(tutorialTalk)
        
        self.talk = tutorialTalk
        
        self.updateView()
    }
    
    fileprivate func endTutorial() {
        nsUserDefaults.set(currentTutorialStage.rawValue, forKey: TUTORIAL_STAGE_PROPERTY_KEY)
        
        //currentUserService.setNewUser(nil)
        
        talkService.clearTalks()
        self.talk = talkService.getSingleModeTalk()
        
        var message = messageCipherService.createMessage(TUTORIAL_TIP1, cipherType: .leftCutter, cipherDifficulty: .normal)
        var remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: self.friendTalk)
        coreMessageService.createMessage(remoteMessage)
        
        message = messageCipherService.createMessage(TUTORIAL_TIP2, cipherType: .shuffle, cipherDifficulty: .normal)
        remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: self.friendTalk)
        coreMessageService.createMessage(remoteMessage)
        
        message = messageCipherService.createMessage(TUTORIAL_TIP3, cipherType: .randomCutter, cipherDifficulty: .normal)
        remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: self.friendTalk)
        coreMessageService.createMessage(remoteMessage)
        
        message = messageCipherService.createMessage(TUTORIAL_TIP4, cipherType: .doubleCutter, cipherDifficulty: .normal)
        remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: self.friendTalk)
        coreMessageService.createMessage(remoteMessage)
        
        message = messageCipherService.createMessage(TUTORIAL_TIP5, cipherType: .rightCutter, cipherDifficulty: .hard)
        remoteMessage = messageCipherService.addNewMessageToTalk(message, talk: self.friendTalk)
        coreMessageService.createMessage(remoteMessage)
        
        talkService.updateTalkInArray(self.friendTalk, withMessages: true)
        
        self.title = currentUserService.getFriendLogin(friendTalk).capitalized
        
        self.updateView()
    }
    
    fileprivate func decipherSendedMessage() {
        let message = talk.messages[talk.messages.count - 1]
        
        for i in 0..<message.words.count {
            let word = message.words[i]
            
            if (word.type == .new) {
                message.words[i].type = .success
            }
        }
        
        for _ in 0...2 {
            let randomIndex = Int(arc4random_uniform(UInt32(message.words.count)))
            
            if (message.words[randomIndex].type == .success) {
                message.words[randomIndex].type = .failed
            }
        }
        
        message.deciphered = true
        
        talk.messages[talk.messages.count - 1] = message
        
        self.updateView()
    }
}
