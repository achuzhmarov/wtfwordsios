import Foundation

class SingleMessageTableView: BaseMessageTableView {
    override func isOutcomingMessageCell(index: Int, message: Message) -> Bool {
        return (index % 2 == 1)
    }
}
