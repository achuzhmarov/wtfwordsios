import Foundation

class NotificationService: Service {
    fileprivate let windowService: WindowService
    fileprivate let messageService: MessageService
    fileprivate let talkService: TalkService

    init(windowService: WindowService, messageService: MessageService, talkService: TalkService) {
        self.windowService = windowService
        self.messageService = messageService
        self.talkService = talkService
    }

    func computeActiveNotification(_ userInfo: [AnyHashable: Any]) {
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
            notification.fireDate = Date()

            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }

    func computeInactiveNotification(_ userInfo: [AnyHashable: Any]) {
        //TODO - realize later
        /*if let author = userInfo["author"] as? String
        {
            showFriendScreen(author)
        }*/
    }
}
