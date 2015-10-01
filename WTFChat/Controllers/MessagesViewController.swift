//
//  MessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

let MESSAGES_UPDATE_TIMER_INTERVAL = 5.0

class MessagesViewController: JSQMessagesViewController {
    var timer: NSTimer?
    
    var currentUser = userService.getCurrentUser()
    var talk: Talk!
    var messages = [Message]()
    var cipherType: CipherType = CipherType.FirstLetterCipher
    
    let incomingUndecipheredBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(
        UIColor.jsq_messageBubbleBlueColor())
    let incomingDecipheredBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(
        UIColor.jsq_messageBubbleGreenColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(
        UIColor.lightGrayColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderDisplayName = currentUser.login
        self.senderId = currentUser.login
        
        if talk.messages.count == 0 && !talk.isSingleMode {
            messageService.getMessagesByTalk(talk) { (messages, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        self.talk.messages = messages!
                        self.updateView()
                    }
                })
            }
        } else {
            self.updateView()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (!talk.isSingleMode) {
            if let updateTimer = timer {
                updateTimer.invalidate()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!talk.isSingleMode) {
            timer = NSTimer.scheduledTimerWithTimeInterval(TALKS_UPDATE_TIMER_INTERVAL, target: self,
                selector: "updateMessages", userInfo: nil, repeats: true)
        }
    }
    
    func updateMessages() {
        messageService.getUnreadMessagesByTalk(talk) { (messages, error) -> Void in
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
    
    func updateView() {
        self.messages = talk.messages
        self.collectionView!.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let message = self.messages[indexPath.row]
        
        var text = ""
        
        if (message.senderId() == self.senderId) {
            text = message.clearText()
        } else {
            text = message.text()
        }
        
        let jsqMessage = JSQMessage(senderId: message.senderId(),
            senderDisplayName: message.senderDisplayName(),
            date: message.date(),
            text: text
        )
        
        return jsqMessage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = self.messages[indexPath.row]
        
        if (message.senderId() == self.senderId) {
            return self.outgoingBubble
        } else if (message.deciphered) {
            return self.incomingDecipheredBubble
        } else {
            return self.incomingUndecipheredBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = self.messages[indexPath.row]
        
        if (message.senderId() != self.senderId) {
            dismissKeyboard()
            performSegueWithIdentifier("showDecipher", sender: message)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        var newMessage = messageCipher.createMessage(self.talk!, text: text, cipherType: cipherType)
        messages.append(newMessage)
        dismissKeyboard()
        
        if (!talk.isSingleMode) {
            messageService.saveMessage(newMessage) { (message, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let requestError = error {
                        //TODO - show error to user
                        print(requestError)
                    } else {
                        if let responseMessage = message {
                            newMessage = responseMessage
                            self.updateView()
                        }
                    }
                })
            }
        } else {
            self.updateView()
        }
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let newCipherType = CipherFactory.getNextCipherType(cipherType)
        
        let refreshAlert = UIAlertController(title: "Change cipher", message: "Are you sure you want to change cipher type to " + newCipherType.description + "?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
            self.cipherType = newCipherType
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
            //do nothing
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! DecipherViewController
            
            let message = sender as! Message
            
            targetController.message = message
            
            //single mode
            targetController.isSingleMode = talk.isSingleMode
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView!.reloadData()
    }
    
    func dismissKeyboard(){
        self.keyboardController.textView!.endEditing(true)
    }
}
