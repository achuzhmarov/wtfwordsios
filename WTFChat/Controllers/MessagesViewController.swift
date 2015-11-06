//
//  MessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, MessageTappedComputer {
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var messageTableView: MessageTableView!
    
    var timer: NSTimer?
    var talk: Talk!
    var cipherType = CipherType.HalfWordRoundDown
    var lastSendedMessage: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = talk.getFriendLogin().capitalizedString

        self.messageTableView.delegate = self.messageTableView
        self.messageTableView.dataSource = self.messageTableView
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.messageTappedComputer = self
        
        if (talk.messages.count == 0 && !talk.isSingleMode) {
            messageService.getMessagesByTalk(talk) { (messages, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        self.talk.messages = messages!
                        self.talk.lastMessage = messages!.last
                        self.talk.decipherStatus = DecipherStatus.No
                        talkService.updateTalkInArray(self.talk, withMessages: true)
                        
                        self.updateView()
                        
                        self.setUpdateTimer()
                    }
                })
            }
        } else if (!talk.isSingleMode) {
            updateMessages()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateView()
        
        if (talk.messages.count != 0) {
            updateMessages()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if (!talk.isSingleMode) {
            if let updateTimer = timer {
                updateTimer.invalidate()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!talk.isSingleMode && talk.messages.count != 0) {
            setUpdateTimer()
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func sendMessage(segue:UIStoryboardSegue) {
        if let sendMessageController = segue.sourceViewController as? SendMessageViewController {
            //check for duplicates
            if (lastSendedMessage != nil) {
                if (lastSendedMessage!.checkEquals(sendMessageController.message)) {
                    return
                }
            }
            
            self.cipherType = sendMessageController.cipherType
            self.lastSendedMessage = sendMessageController.message
            
            let newMessage = messageCipher.addNewMessageToTalk(self.lastSendedMessage!, talk: self.talk!)
            talkService.updateTalkInArray(self.talk, withMessages: true)
            
            //let text = self.inputToolbar?.contentView?.textView?.text
            //let newMessage = messageCipher.createMessage(self.talk!, text: text!, cipherType: cipherType)
            dismissKeyboard()
            
            if (!talk.isSingleMode) {
                messageService.saveMessage(newMessage) { (message, error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let requestError = error {
                            //TODO - show error to user
                            print(requestError)
                        } else {
                            if let responseMessage = message {
                                self.talk.messages[self.talk.messages.count - 1] = responseMessage
                                talkService.updateTalkInArray(self.talk, withMessages: true)
                                
                                self.updateView(true)
                            }
                        }
                    })
                }
            } else {
                self.updateView(true)
            }
        }
    }
    
    func messageTapped(message: Message) {
        performSegueWithIdentifier("showDecipher", sender: message)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! DecipherViewController
            
            let message = sender as! Message
            
            targetController.message = message
            targetController.talk = talk
            
            //single mode
            targetController.isSingleMode = talk.isSingleMode
            
            //self message - view only
            if (message.author == userService.getUserLogin()) {
                targetController.selfAuthor = true
                
                if (!message.deciphered) {
                    targetController.useCipherText = true
                }
            }
        } else if segue.identifier == "showMessagePreview" {
            let targetController = segue.destinationViewController as! SendMessageViewController
            
            let text = sender as! String
            updateLastCipherType()
            
            targetController.text = text
            targetController.cipherType = self.cipherType
        }
    }
    
    func updateLastCipherType() {
        for message in talk.messages {
            if (message.author == userService.getUserLogin() || talk.isSingleMode) {
                self.cipherType = message.cipherType
            }
        }
    }
    
    func dismissKeyboard(){
        self.messageText.endEditing(true)
    }
    
    /*override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        header headerView: JSQMessagesLoadEarlierHeaderView!,
        didTapLoadEarlierMessagesButton sender: UIButton)
    {
        messageService.getEarlierMessagesByTalk(talk, skip: talk.messages.count) { (messages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    if let newMessages = messages {
                        for message in newMessages {
                            self.updateOrCreateMessageInArray(message)
                        }
                        
                        self.updateView(false, earlierLoaded: newMessages.count)
                    }
                }
            })
        }
    }*/
    
    func getMessagesLastUpdate() -> NSDate {
        var lastUpdate: NSDate?
        
        for message in talk.messages {
            //ignore local messages
            if (message.isLocal) {
                continue
            }
            
            if (lastUpdate == nil || message.lastUpdate.isGreater(lastUpdate!)) {
                lastUpdate = message.lastUpdate
            }
        }
        
        if (lastUpdate != nil) {
            return lastUpdate!
        } else {
            return NSDate.defaultPast()
        }
    }
    
    func updateMessages() {
        let lastUpdate = getMessagesLastUpdate()
        
        messageService.getUnreadMessagesByTalk(talk, lastUpdate: lastUpdate) { (messages, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    if let newMessages = messages {
                        for message in newMessages {
                            self.updateOrCreateMessageInArray(message)
                        }
                        
                        self.updateView()
                    }
                }
            })
        }
    }
    
    func updateOrCreateMessageInArray(message: Message) {
        for i in 0..<self.talk.messages.count {
            if (message.id == self.talk.messages[i].id) {
                self.talk.messages[i] = message
                return
            }
        }
        
        self.talk.messages.append(message)
    }
    
    private func updateView(withSend: Bool = false, earlierLoaded: Int = 0) {
        talk.messages.sortInPlace { (message1, message2) -> Bool in
            return message1.timestamp.isLess(message2.timestamp)
        }
        
        /*if (talk.messages.count != 0 && talk.messageCount > talk.messages.count) {
            showLoadEarlierMessagesHeader = true
        } else {
            showLoadEarlierMessagesHeader = false
        }*/
        
        self.messageTableView.updateTalk(self.talk)
        
        /*if (withoutSend && self.keyboardController.textView!.text.characters.count > 0) {
        self.keyboardController.textView!.becomeFirstResponder()
        }*/
        
        /*if (withSend) {
            finishSendingMessageAnimated(false)
        } else if (earlierLoaded == 0) {
            finishReceivingMessageAnimated(false)
        } else if (earlierLoaded > 0) {
            let indexPath = NSIndexPath(forItem: earlierLoaded - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }*/
        
        self.talk.decipherStatus = DecipherStatus.No
        self.talk.lastMessage = self.talk.messages.last
        talkService.updateTalkInArray(self.talk, withMessages: true)
    }
    
    private func setUpdateTimer() {
        if let updateTimer = timer {
            updateTimer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(TALKS_UPDATE_TIMER_INTERVAL, target: self,
            selector: "updateMessages", userInfo: nil, repeats: true)
    }
}
