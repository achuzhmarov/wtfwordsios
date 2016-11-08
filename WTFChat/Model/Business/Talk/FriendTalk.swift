import Foundation

enum DecipherStatus: Int {
    case no = 1, success, failed
}

class FriendTalk: Talk {
    let id: String
    var users = [String]()
    var hasUnread: Bool = false
    var decipherStatus = DecipherStatus.no
    var cipheredNum: Int = 0
    var lastUpdate: Date = Date()
    var messageCount: Int = 0

    var lastMessage: RemoteMessage?
    var isSingleMode = false

    init(id: String) {
        self.id = id;

        super.init()
    }

    init(id: String, hasUnread: Bool, cipheredNum: Int, lastMessage: RemoteMessage?, users: [String], decipherStatus: DecipherStatus, lastUpdate: Date, messageCount: Int) {
        self.id = id;
        self.hasUnread = hasUnread
        self.cipheredNum = cipheredNum
        self.lastMessage = lastMessage
        self.users = users
        self.decipherStatus = decipherStatus
        self.lastUpdate = lastUpdate
        self.messageCount = messageCount

        super.init()
    }

    func appendMessage(_ message: RemoteMessage) {
        messages.append(message)
        lastMessage = message
    }
}
