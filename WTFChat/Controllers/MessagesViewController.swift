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

    var cipherType: CipherType = CipherType.HalfWordRoundDown
    
    let inCipheredBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(CIPHERED_COLOR)
    let outCipheredBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(CIPHERED_COLOR)
    
    let inSuccessBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(SUCCESS_COLOR)
    let outSuccessBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(SUCCESS_COLOR)
    
    let inFailedBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(FAILED_COLOR)
    let outFailedBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(FAILED_COLOR)
    
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    
    //flag to show when we return from SendPreview. Used in viewDidAppear to finish message sending
    var messageSended = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
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
                        self.talk.decipherStatus = DecipherStatus.No
                        self.updateView()
                        self.finishSendingMessageAnimated(false)
                    }
                })
            }
        } else {
            self.updateView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView!.reloadData()
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
        
        //send message
        if (messageSended) {
            messageSended = false
            let text = self.inputToolbar?.contentView?.textView?.text
            
            let newMessage = messageCipher.createMessage(self.talk!, text: text!, cipherType: cipherType)
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
        self.collectionView!.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView!.textColor = FONT_COLOR
    
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let message = self.talk.messages[indexPath.row]
        
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
        
        let message = self.talk.messages[indexPath.row]
        
        if (message.senderId() == self.senderId) {
            if (message.deciphered) {
                if (message.countFailed() > 0) {
                    return self.outFailedBubble
                } else {
                    return self.outSuccessBubble
                }
            } else {
                return self.outCipheredBubble
            }
        } else {
            if (message.deciphered) {
                if (message.countFailed() > 0) {
                    return self.inFailedBubble
                } else {
                    return self.inSuccessBubble
                }
            } else {
                return self.inCipheredBubble
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let message = self.talk.messages[indexPath.row]
        
        if (message.senderId() != self.senderId || message.deciphered) {
            dismissKeyboard()
            performSegueWithIdentifier("showDecipher", sender: message)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = self.talk.messages[indexPath.row]
        
        if let avatar = avatars[message.author] {
            return avatar
        } else {
            let incoming = (message.senderId() == self.senderId)
            avatars[message.author] = setupAvatarImage(message.author, imageUrl: nil, incoming: incoming)
            return avatars[message.author]
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.talk.messages.count;
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        performSegueWithIdentifier("showMessagePreview", sender: text)
    }
    
    @IBAction func sendMessage(segue:UIStoryboardSegue) {
        if let sendMessageController = segue.sourceViewController as? SendMessageViewController {
            self.cipherType = sendMessageController.cipherType
            messageSended = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! DecipherViewController
            
            let message = sender as! Message
            
            targetController.message = message
            targetController.talk = talk
            
            //single mode
            targetController.isSingleMode = talk.isSingleMode
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
            if (message.senderId() == self.senderId || talk.isSingleMode) {
                self.cipherType = message.cipherType
            }
        }
    }
    
    func dismissKeyboard(){
        self.keyboardController.textView!.endEditing(true)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) -> JSQMessagesAvatarImage {
        //TODO How to get avatar image?
        
        /*if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }*/
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        let diameter = incoming ? UInt(collectionView!.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView!.collectionViewLayout.outgoingAvatarViewSize.width)
        return userService.getAvatarImage(name, diameter: diameter)
    }
}
