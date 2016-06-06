import Foundation

class SingleCipherTalk {
    let id: String
    var messages = [Message]()

    init(id: String) {
        self.id = id;
    }

    func appendMessage(message: Message) {
        messages.append(message)
    }
}
