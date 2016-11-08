import UIKit

class MessagesViewController: BaseMessageViewController, MessageListener {
    fileprivate let messageService: MessageService = serviceLocator.get(MessageService.self)
    fileprivate let talkService: TalkService = serviceLocator.get(TalkService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let messageCipherService: MessageCipherService = serviceLocator.get(MessageCipherService.self)
    fileprivate let coreMessageService: CoreMessageService = serviceLocator.get(CoreMessageService.self)

    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var messageTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var refreshControl:UIRefreshControl!
    
    var timer: Foundation.Timer?
    var cipherType = CipherType.rightCutter
    var cipherDifficulty = CipherDifficulty.normal
    var lastSendedMessage: Message?

    var defaultMessageTextHeightConstraint: CGFloat!
    var isKeyboardShown = false
    
    var wasSuccessfullUpdate = false

    var friendTalk: FriendTalk!

    override func viewDidLoad() {
        super.viewDidLoad()

        friendTalk = talk as! FriendTalk

        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessagesViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        let friendInfo = currentUserService.getFriendInfoByTalk(friendTalk)
        let title = "\(friendInfo!.getDisplayName()), lvl \(String(friendInfo!.lvl))"
        configureTitleView(title, navigationItem: navigationItem)

        messageService.initMessageListener(friendTalk, listener: self)
        
        DispatchQueue.main.async(execute: {
            self.updateViewAfterGetNew()
        })
        
        messageText.layer.cornerRadius = 5
        messageText.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        messageText.layer.borderWidth = 0.5
        messageText.clipsToBounds = true
        messageText.textContainerInset = UIEdgeInsets(top: 3.5, left: 5, bottom: 2, right: 5);
        
        messageText.delegate = self
        
        defaultMessageTextHeightConstraint = messageTextHeightConstraint.constant
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        messageService.removeListener(friendTalk)
    }

    fileprivate func configureTitleView(_ title: String, navigationItem: UINavigationItem) {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        titleLabel.sizeToFit()
        titleLabel.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: - Navigation
    
    @IBAction func sendMessage(_ segue:UIStoryboardSegue) {
        if let sendMessageController = segue.source as? SendMessageViewController {
            //check for duplicates
            if (lastSendedMessage != nil) {
                if (lastSendedMessage!.checkEquals(sendMessageController.message)) {
                    return
                }
            }
            
            self.cipherType = sendMessageController.cipherType
            self.cipherDifficulty = sendMessageController.cipherDifficulty
            self.lastSendedMessage = sendMessageController.message
            
            let newMessage = messageCipherService.addNewMessageToTalk(self.lastSendedMessage!, talk: self.friendTalk!)
            talkService.updateTalkInArray(self.friendTalk, withMessages: true)
            
            if (!friendTalk.isSingleMode) {
                messageService.createMessage(newMessage)
            } else {
                coreMessageService.createMessage(newMessage)
            }

            updateViewAfterSend()
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        if (messageText.text.characters.count > 1024) {
            WTFOneButtonAlert.show("Too many characters",
                message: "Your text should be less than 1024 characters",
                firstButtonTitle: "Ok")
            return
        }
        
        self.performSegue(withIdentifier: "showMessagePreview", sender: messageText.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let message = messageText.text {
            sendButton.isEnabled = (message.characters.count > 0)
        } else {
            sendButton.isEnabled = false
        }
        
        let contentSize = self.messageText.sizeThatFits(self.messageText.bounds.size)

        let nav = self.navigationController!.navigationBar
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let padding = self.bottomViewConstraint.constant + nav.bounds.height + statusBarHeight + 32
        
        let maxHeight = self.view.bounds.height - padding
        
        if (contentSize.height < maxHeight) {
            messageText.isScrollEnabled = false
            messageTextHeightConstraint.constant = contentSize.height
        } else {
            messageText.isScrollEnabled = true
        }
    }
    
    fileprivate func updateLastCipherType() {
        for message in talk.messages {
            if ((message as! RemoteMessage).author == currentUserService.getUserLogin() || friendTalk.isSingleMode) {
                self.cipherType = message.cipherType
                self.cipherDifficulty = message.cipherDifficulty
            }
        }
    }
    
    func dismissKeyboard() {
        self.messageText.endEditing(true)
    }
    
    //delegate for MessageListener
    func updateMessages(_ talk: FriendTalk?, wasNew: Bool, error: NSError?) {
        DispatchQueue.main.async(execute: {
            if let requestError = error {
                if (!self.wasSuccessfullUpdate) {
                    WTFOneButtonAlert.show("Error", message: "Can't load messages. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok")
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
    func loadEarlierCompleteHandler(_ talk: FriendTalk?, newMessagesCount: Int, error: NSError?) {
        DispatchQueue.main.async(execute: {
            if let requestError = error {
                WTFOneButtonAlert.show("Error", message: "Can't load earlier messages. \(WTFOneButtonAlert.CON_ERR)", firstButtonTitle: "Ok")

                NSLog(requestError.localizedDescription)
            } else {
                self.talk = talk
                self.updateViewAfterGetEarlier(newMessagesCount)
            }
            
            self.refreshControl.endRefreshing()
        })
    }
    
    //delegate for MessageListener
    func messageSended(_ talk: FriendTalk?, error: NSError?) {
        DispatchQueue.main.async(execute: {
            if let requestError = error {
                print(requestError)
            } else {
                self.talk = talk
                //now without send=true (because input text field was cleared early)
                self.updateView()
            }
        })
    }
    
    //refreshControl delegate
    func loadEarlier(_ sender:AnyObject) {
        messageService.loadEarlier(friendTalk.id)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.size.height
        
        messageTableView.contentOffset = CGPoint(x: messageTableView.contentOffset.x,
            y: messageTableView.contentOffset.y + keyboardHeight)
        
        self.bottomViewConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
        
        self.isKeyboardShown = true
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.size.height
        
        messageTableView.contentOffset = CGPoint(x: messageTableView.contentOffset.x,
            y: messageTableView.contentOffset.y - keyboardHeight)
        
        self.bottomViewConstraint.constant = 0
        self.view.layoutIfNeeded()
        
        self.isKeyboardShown = false
        
        self.updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "showDecipher" {
            let targetController = segue.destination as! DecipherViewController

            let message = sender as! RemoteMessage

            targetController.message = message

            //self message - view only
            if (message.author == currentUserService.getUserLogin()) {
                targetController.selfAuthor = true

                if (!message.deciphered) {
                    targetController.useCipherText = true
                }
            }
        } else if segue.identifier == "showMessagePreview" {
            let targetController = segue.destination as! SendMessageViewController
            
            let text = sender as! String
            updateLastCipherType()
            
            targetController.text = text
            targetController.cipherType = self.cipherType
            targetController.isSingleMode = friendTalk.isSingleMode
        }
        
        dismissKeyboard()
    }

    override func updateView() {
        talk = talkService.getByTalkId(friendTalk.id)

        if ((talk.messages.count != 0) && (friendTalk.messageCount > talk.messages.count)) {
            createRefreshControl()
        } else {
            deleteRefreshControl()
        }

        if  (!self.isKeyboardShown) {
            //update GUI only if keyboard hidden
            self.messageTableView.updateTalk(self.friendTalk)

            talkService.talkViewed(self.friendTalk.id)
        }
    }

    func updateViewAfterSend() {
        updateView()

        dismissKeyboard()

        messageText.text = ""
        sendButton.isEnabled = false
        messageText.isScrollEnabled = false
        messageTextHeightConstraint.constant = defaultMessageTextHeightConstraint

        messageTableView.scrollTableToBottom()
    }

    func updateViewAfterGetEarlier(_ earlierLoaded: Int) {
        updateView()

        if  (!self.isKeyboardShown) {
            messageTableView.scrollTableToEarlier(earlierLoaded - 1)
        }
    }

    func updateViewAfterGetNew() {
        updateView()

        messageTableView.scrollTableToBottom()
    }

    fileprivate func createRefreshControl() {
        deleteRefreshControl()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to load more")
        refreshControl.addTarget(self, action: #selector(MessageService.loadEarlier(_:)), for: UIControlEvents.valueChanged)
        self.messageTableView.addSubview(refreshControl)
        //self.messageTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    fileprivate func deleteRefreshControl() {
        self.refreshControl?.endRefreshing()
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }
}
