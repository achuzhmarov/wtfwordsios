//
//  MessagesViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, MessageTappedComputer, UITextViewDelegate, MessageListener {
    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: MessageTableView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var refreshControl:UIRefreshControl!
    
    var timer: NSTimer?
    var talk: Talk!
    var cipherType = CipherType.HalfWordRoundDown
    var lastSendedMessage: Message?
    var firstTimeLoaded = true

    var defaultMessageTextHeightConstraint: CGFloat!
    
    var isKeyboardShown = false
    
    var wasSuccessfullUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        if (talk.isSingleMode) {
            self.title = talk.getFriendLogin().capitalizedString
        } else {
            let friendInfo = currentUserService.getFriendInfoByLogin(talk.getFriendLogin())
            let title = "\(friendInfo!.getDisplayName()), lvl \(String(friendInfo!.lvl))"
            configureTitleView(title, navigationItem: navigationItem)
        }
        
        self.messageTableView.delegate = self.messageTableView
        self.messageTableView.dataSource = self.messageTableView
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.messageTappedComputer = self
        
        if (!talk.isSingleMode) {
            messageService.initMessageListener(talk, listener: self)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.updateView(false, earlierLoaded: 0, wasNew: true)
        })
        
        self.messageTableView.alpha = 0
        
        messageText.layer.cornerRadius = 5
        messageText.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        messageText.layer.borderWidth = 0.5
        messageText.clipsToBounds = true
        messageText.textContainerInset = UIEdgeInsets(top: 3.5, left: 5, bottom: 2, right: 5);
        
        messageText.delegate = self
        
        defaultMessageTextHeightConstraint = messageTextHeightConstraint.constant
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        messageService.removeListener(talk)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (talk.messages.count > 0) {
            self.updateView()
            
            if (self.messageTableView.alpha == 0) {
                firstTimeLoaded = false
                
                let delay = Double(talk.messages.count) / 200.0
                showMessages(0.5, delay: delay)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstTimeLoaded) {
            firstTimeLoaded = false
            
            showMessages(0.3, delay: 0)
        }
    }
    
    func showMessages(duration: NSTimeInterval, delay: NSTimeInterval) {
        UIView.animateWithDuration(duration, delay: delay,
            options: [], animations: {
                self.messageTableView.alpha = 1
            }, completion: nil)
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
            
            if (!talk.isSingleMode) {
                messageService.createMessage(newMessage)
            } else {
                CoreMessage.createMessage(newMessage)

                self.updateView(true)
            }
        }
    }
    
    func messageTapped(message: Message) {
        performSegueWithIdentifier("showDecipher", sender: message)
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        if (messageText.text.characters.count > 1024) {
            WTFOneButtonAlert.show("Too many characters",
                message: "Your text should be less than 1024 characters",
                firstButtonTitle: "Ok",
                viewPresenter: self)
            return
        }
        
        self.performSegueWithIdentifier("showMessagePreview", sender: messageText.text)
    }
    
    func textViewDidChange(textView: UITextView) {
        if (messageText.text?.characters.count > 0) {
            sendButton.enabled = true
        } else {
            sendButton.enabled = false
        }
        
        let contentSize = self.messageText.sizeThatFits(self.messageText.bounds.size)

        let nav = self.navigationController!.navigationBar
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let padding = self.bottomViewConstraint.constant + nav.bounds.height + statusBarHeight + 32
        
        let maxHeight = self.view.bounds.height - padding
        
        if (contentSize.height < maxHeight) {
            messageText.scrollEnabled = false
            messageTextHeightConstraint.constant = contentSize.height
        } else {
            messageText.scrollEnabled = true
        }
    }
    
    func updateLastCipherType() {
        for message in talk.messages {
            if (message.author == currentUserService.getUserLogin() || talk.isSingleMode) {
                self.cipherType = message.cipherType
            }
        }
    }
    
    func dismissKeyboard() {
        self.messageText.endEditing(true)
    }
    
    //delegate for MessageListener
    func updateMessages(talk: Talk?, wasNew: Bool, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let requestError = error {
                if (!self.wasSuccessfullUpdate) {
                    WTFOneButtonAlert.show("Error", message: "Can't load messages. \(connectionErrorDescription())", firstButtonTitle: "Ok", viewPresenter: self)
                }
                
                NSLog(requestError.localizedDescription)
            } else {
                self.wasSuccessfullUpdate = true
                self.talk = talk
                self.updateView(false, earlierLoaded: 0, wasNew: wasNew)
            }
        })
    }
    
    //delegate for MessageListener
    func loadEarlierCompleteHandler(talk: Talk?, newMessagesCount: Int, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let requestError = error {
                WTFOneButtonAlert.show("Error", message: "Can't load earlier messages. \(connectionErrorDescription())", firstButtonTitle: "Ok", viewPresenter: self)

                NSLog(requestError.localizedDescription)
            } else {
                self.talk = talk
                self.updateView(false, earlierLoaded: newMessagesCount)
            }
            
            self.refreshControl.endRefreshing()
        })
    }
    
    //delegate for MessageListener
    func messageSended(talk: Talk?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let requestError = error {
                //TODO - show error to user
                print(requestError)
            } else {
                self.talk = talk
                self.updateView(true)
            }
        })
    }
    
    //refreshControl delegate
    func loadEarlier(sender:AnyObject) {
        messageService.loadEarlier(talk.id)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardFrame.size.height
        
        messageTableView.contentOffset = CGPointMake(messageTableView.contentOffset.x,
            messageTableView.contentOffset.y + keyboardHeight)
        
        self.bottomViewConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
        
        self.isKeyboardShown = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight = keyboardFrame.size.height
        
        messageTableView.contentOffset = CGPointMake(messageTableView.contentOffset.x,
            messageTableView.contentOffset.y - keyboardHeight)
        
        self.bottomViewConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        self.isKeyboardShown = false
        
        self.updateView()
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
            if (message.author == currentUserService.getUserLogin()) {
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
            targetController.isSingleMode = talk.isSingleMode
        }
        
        dismissKeyboard()
    }
    
    func updateView(withSend: Bool = false, earlierLoaded: Int = 0, wasNew: Bool = false) {
        //update talk
        talk = talkService.getByTalkId(talk.id)
        
        if (talk.messages.count != 0 && talk.messageCount > talk.messages.count) {
            createRefreshControl()
        } else {
            deleteRefreshControl()
        }

        if  (!self.isKeyboardShown) {
            //update GUI only if keyboard hidden
            self.messageTableView.updateTalk(self.talk)
            talkService.talkViewed(self.talk.id)
            
            if (earlierLoaded > 0) {
                self.messageTableView.scrollTableToEarlier(earlierLoaded - 1)
            } else if (wasNew) {
                self.messageTableView.scrollTableToBottom()
            }
        }
        
        if (withSend) {
            dismissKeyboard()
            messageText.text = ""
            sendButton.enabled = false
            messageText.scrollEnabled = false
            messageTextHeightConstraint.constant = defaultMessageTextHeightConstraint
            
            self.messageTableView.scrollTableToBottom()
        }
    }
    
    private func createRefreshControl() {
        deleteRefreshControl()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to load more")
        refreshControl.addTarget(self, action: "loadEarlier:", forControlEvents: UIControlEvents.ValueChanged)
        self.messageTableView.addSubview(refreshControl)
        //self.messageTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    private func deleteRefreshControl() {
        self.refreshControl?.endRefreshing()
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }
}
