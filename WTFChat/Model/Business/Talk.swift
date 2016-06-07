import Foundation

enum DecipherStatus: Int {
    case No = 1, Success, Failed
}

class Talk: NSObject {
    let id: String
    var users = [String]()
    var hasUnread: Bool = false
    var decipherStatus = DecipherStatus.No
    var cipheredNum: Int = 0
    var lastUpdate: NSDate = NSDate()
    var messageCount: Int = 0

    var messages = [RemoteMessage]()

    var lastMessage: RemoteMessage?
    var isSingleMode = false

    init(id: String) {
        self.id = id;
    }

    init(id: String, hasUnread: Bool, cipheredNum: Int, lastMessage: RemoteMessage?, users: [String], decipherStatus: DecipherStatus, lastUpdate: NSDate, messageCount: Int) {
        self.id = id;
        self.hasUnread = hasUnread
        self.cipheredNum = cipheredNum
        self.lastMessage = lastMessage
        self.users = users
        self.decipherStatus = decipherStatus
        self.lastUpdate = lastUpdate
        self.messageCount = messageCount
    }

    func appendMessage(message: RemoteMessage) {
        messages.append(message)
        lastMessage = message
    }
}
