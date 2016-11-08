import Foundation

class SingleMessageTableView: BaseMessageTableView {
    override func isOutcomingMessageCell(_ index: Int, message: Message) -> Bool {
        return (index % 2 == 1)
    }
}
