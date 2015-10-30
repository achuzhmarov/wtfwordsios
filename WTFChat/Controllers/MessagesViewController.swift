//
//  MessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

let MESSAGES_UPDATE_TIMER_INTERVAL = 10.0
let INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS = 10 * 60

class MessagesViewController: JSQMessagesViewController {
    var timer: NSTimer?
    
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
    var messageToSend: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = talk.getFriendLogin().capitalizedString

        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
        self.senderDisplayName = userService.getUserLogin()
        self.senderId = userService.getUserLogin()

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
        
        if (talk.messages.count != 0) {
            updateMessages()
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
    
    func setUpdateTimer() {
        if let updateTimer = timer {
            updateTimer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(TALKS_UPDATE_TIMER_INTERVAL, target: self,
            selector: "updateMessages", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (!talk.isSingleMode && talk.messages.count != 0) {
            setUpdateTimer()
        }
        
        //send message
        if (messageSended) {
            messageSended = false
            let newMessage = messageCipher.addNewMessageToTalk(self.messageToSend!, talk: self.talk!)
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
    
    func updateView(withSend: Bool = false, earlierLoaded: Int = 0) {
        talk.messages.sortInPlace { (message1, message2) -> Bool in
            return message1.timestamp.isLess(message2.timestamp)
        }
        
        if (talk.messages.count != 0 && talk.messageCount > talk.messages.count) {
            showLoadEarlierMessagesHeader = true
        } else {
            showLoadEarlierMessagesHeader = false
        }
        
        self.collectionView!.reloadData()
        
        /*if (withoutSend && self.keyboardController.textView!.text.characters.count > 0) {
            self.keyboardController.textView!.becomeFirstResponder()
        }*/
        
        if (withSend) {
            finishSendingMessageAnimated(false)
        } else if (earlierLoaded == 0) {
            finishReceivingMessageAnimated(false)
        } else if (earlierLoaded > 0) {
            let indexPath = NSIndexPath(forItem: earlierLoaded - 1, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        }
        
        self.talk.decipherStatus = DecipherStatus.No
        self.talk.lastMessage = self.talk.messages.last
        talkService.updateTalkInArray(self.talk, withMessages: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(
        collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView!.textColor = FONT_COLOR
    
        return cell
    }
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        messageDataForItemAtIndexPath indexPath: NSIndexPath!)
        -> JSQMessageData!
    {
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
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!)
        -> JSQMessageBubbleImageDataSource!
    {
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
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!)
    {
        let message = self.talk.messages[indexPath.row]
        
        dismissKeyboard()
        performSegueWithIdentifier("showDecipher", sender: message)
    }
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!)
        -> JSQMessageAvatarImageDataSource!
    {
        let message = self.talk.messages[indexPath.row]
        
        if let avatar = avatars[message.author] {
            return avatar
        } else {
            let incoming = (message.senderId() == self.senderId)
            avatars[message.author] = setupAvatarImage(message.author, imageUrl: nil, incoming: incoming)
            return avatars[message.author]
        }
    }
    
    override func collectionView(
        collectionView: UICollectionView,
        numberOfItemsInSection section: Int)
        -> Int {
            
        return self.talk.messages.count;
    }
    
    override func didPressSendButton(
        button: UIButton!,
        withMessageText text: String!,
        senderId: String!,
        senderDisplayName: String!,
        date: NSDate!)
    {
        dismissKeyboard()
        performSegueWithIdentifier("showMessagePreview", sender: text)
    }
    
    @IBAction func sendMessage(segue:UIStoryboardSegue) {
        if let sendMessageController = segue.sourceViewController as? SendMessageViewController {
            //check for duplicates
            if (messageToSend != nil) {
                if (messageToSend!.checkEquals(sendMessageController.message)) {
                    return
                }
            }
            
            self.cipherType = sendMessageController.cipherType
            self.messageToSend = sendMessageController.message
            self.messageSended = true
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
            
            //self message - view only
            if (message.senderId() == self.senderId) {
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
    
    //Top Cell Label
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!)
        -> NSAttributedString?
    {
        let message = self.talk.messages[indexPath.row]
        
        if (indexPath.row == 0) {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.timestamp)
        } else {
            let prevMessage = self.talk.messages[indexPath.row - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSinceDate(prevMessage.timestamp))
            
            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.timestamp)
            }
        }
        
        return nil;
    }

    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!)
        -> CGFloat
    {
        let message = self.talk.messages[indexPath.row]
        
        if (indexPath.row == 0) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            let prevMessage = self.talk.messages[indexPath.row - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSinceDate(prevMessage.timestamp))
            
            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
            
        return 0.0;
    }
    
    override func collectionView(
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
    }
    
    //Bottom Cell Label
    
    /*override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!)
        -> NSAttributedString?
    {
        let message = self.talk.messages[indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedTime = formatter.stringFromDate(message.timestamp)
        
        let result = NSAttributedString(string: formattedTime)
        return result
    }
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!)
        -> CGFloat
    {
        return 10.0
    }*/
    
    //Top Bubble Label
    
    /*override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!)
        -> NSAttributedString?
    {
        /*JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
            
        if ([message.senderId isEqualToString:self.senderId]) {
            return nil;
        }
            
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
            if ([[previousMessage senderId] isEqualToString:message.senderId]) {
                return nil;
            }
        }*/
            
        //return NSAttributedString.init(string: message.senderDisplayName)
        return NSAttributedString.init(string: "")
    }
    
    override func collectionView(
        collectionView: JSQMessagesCollectionView!,
        layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
        heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!)
        -> CGFloat
    {
        /*JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
        if ([[currentMessage senderId] isEqualToString:self.senderId]) {
            return 0.0f;
        }
            
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
            if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
                return 0.0f;
            }
        }*/
            
        //return kJSQMessagesCollectionViewCellLabelHeightDefault;
        return 0.0
    }*/
}
