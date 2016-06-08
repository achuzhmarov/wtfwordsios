import Foundation

class Talk: NSObject {
    var messages = [Message]()

    override init() {
        super.init()
    }

    init(messages: [Message]) {
        self.messages = messages
    }
}
