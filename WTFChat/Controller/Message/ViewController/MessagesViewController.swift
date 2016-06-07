import UIKit

class MessagesViewController: BaseMessageViewController, MessageListener {
    private let messageService: MessageService = serviceLocator.get(MessageService)
    private let talkService: TalkService = serviceLocator.get(TalkService)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    private let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService)
    private let coreMessageService: CoreMessageService = serviceLocator.get(CoreMessageService)

    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var refreshControl:UIRefreshControl!
    
    var timer: NSTimer?
    var cipherType = CipherType.RightCutter
    var cipherDifficulty = CipherDifficulty.Normal
    var lastSendedMessage: Message?

    var defaultMessageTextHeightConstraint: CGFloat!
    var isKeyboardShown = false
    
    var wasSuccessfullUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessagesViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        let friendInfo = currentUserService.getFriendInfoByTalk(talk)
        let title = "\(friendInfo!.getDisplayName()), lvl \(String(friendInfo!.lvl))"
        configureTitleView(title, navigationItem: navigationItem)

        messageService.initMessageListener(talk, listener: self)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.updateViewAfterGetNew()
        })
        
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

    private func configureTitleView(title: String, navigationItem: UINavigationItem) {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        titleLabel.sizeToFit()
        titleLabel.adjustsFontSizeToFitWidth = true
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
            self.cipherDifficulty = sendMessageController.cipherDifficulty
            self.lastSendedMessage = sendMessageController.message
            
            let newMessage = messageCipherService.addNewMessageToTalk(self.lastSendedMessage!, talk: self.talk!)
            talkService.updateTalkInArray(self.talk, withMessages: true)
            
            if (!talk.isSingleMode) {
                messageService.createMessage(newMessage)
            } else {
                coreMessageService.createMessage(newMessage)
            }

            updateViewAfterSend()
        }
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
    
    private func updateLastCipherType() {
        for message in talk.messages {
            if (message.author == currentUserService.getUserLogin() || talk.isSingleMode) {
                self.cipherType = message.cipherType
                self.cipherDifficulty = message.cipherDifficulty
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
                    WTFOneButtonAlert.show("Error", message: "Can't load messages. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok", viewPresenter: self)
                }
                
                NSLog(requestError.localizedDescription)
            } else {
                self.wasSuccessfullUpdate = true
                self.talk = talk

                if (wasNew) {
                    self.updateViewAfterGetNew()
                } else {
                    self.updateView()
                }
            }
        })
    }
    
    //delegate for MessageListener
    func loadEarlierCompleteHandler(talk: Talk?, newMessagesCount: Int, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let requestError = error {
                WTFOneButtonAlert.show("Error", message: "Can't load earlier messages. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok", viewPresenter: self)

                NSLog(requestError.localizedDescription)
            } else {
                self.talk = talk
                self.updateViewAfterGetEarlier(newMessagesCount)
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
                //TODO - now without send=true (because input text field was cleared early)
                self.updateView()
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
        super.prepareForSegue(segue, sender: sender)

        if segue.identifier == "showDecipher" {
            let targetController = segue.destinationViewController as! DecipherViewController

            let message = sender as! RemoteMessage

            targetController.message = message
            targetController.talk = talk

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

    override func updateView() {
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
        }
    }

    func updateViewAfterSend() {
        updateView()

        dismissKeyboard()

        messageText.text = ""
        sendButton.enabled = false
        messageText.scrollEnabled = false
        messageTextHeightConstraint.constant = defaultMessageTextHeightConstraint

        messageTableView.scrollTableToBottom()
    }

    func updateViewAfterGetEarlier(earlierLoaded: Int) {
        updateView()

        if  (!self.isKeyboardShown) {
            messageTableView.scrollTableToEarlier(earlierLoaded - 1)
        }
    }

    func updateViewAfterGetNew() {
        updateView()

        messageTableView.scrollTableToBottom()
    }

    private func createRefreshControl() {
        deleteRefreshControl()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to load more")
        refreshControl.addTarget(self, action: #selector(MessageService.loadEarlier(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.messageTableView.addSubview(refreshControl)
        //self.messageTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    private func deleteRefreshControl() {
        self.refreshControl?.endRefreshing()
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }
}
