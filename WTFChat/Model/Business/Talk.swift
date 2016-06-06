import Foundation

class Talk: JsonTalk {
    func appendMessage(message: Message) {
        messages.append(message)
        lastMessage = message
    }
}
