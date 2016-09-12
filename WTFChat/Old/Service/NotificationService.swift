import Foundation

class NotificationService: Service {
    private let windowService: WindowService
    private let messageService: MessageService
    private let talkService: TalkService

    init(windowService: WindowService, messageService: MessageService, talkService: TalkService) {
        self.windowService = windowService
        self.messageService = messageService
        self.talkService = talkService
    }

    func computeActiveNotification(userInfo: [NSObject : AnyObject]) {
        talkService.getNewUnreadTalks()

        let currentController = windowService.getCurrentController()
        if let messageViewController = currentController as? MessagesViewController {
            messageService.updateMessages(messageViewController.friendTalk.id)
        }

        //show localNotification (added to ios notifications window)
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let notification = UILocalNotification()
            notification.alertBody = info["alert"] as? String
            notification.fireDate = NSDate()

            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }

    func computeInactiveNotification(userInfo: [NSObject : AnyObject]) {
        //TODO - realize later
        /*if let author = userInfo["author"] as? String
        {
            showFriendScreen(author)
        }*/
    }
}
