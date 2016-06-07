import Foundation

protocol MessageTappedComputer: class {
    func messageTapped(message: Message)
}

class BaseMessageTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    private final let INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS = 10 * 60

    var talk: FriendTalk!

    weak var messageTappedComputer: MessageTappedComputer?

    func updateTalk(talk: FriendTalk) {
        self.talk = talk
        self.reloadData()
    }

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (talk == nil) {
            return 0
        }

        return talk!.messages.count
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = talk.messages[indexPath.row]

        var height = 35.5

        if (needShowTime(indexPath.row, message: message)) {
            height += 20
        }

        return CGFloat(height)
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = talk.messages[indexPath.row]

        let isOutcoming = isOutcomingMessageCell(indexPath.row, message: message)
        let cellIdentifier = getCellIdentifier(indexPath.row, message: message, isOutcoming: isOutcoming)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BaseMessageCell

        cell.updateMessage(message, isOutcoming: isOutcoming)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageTableView.messageTapped(_:)))
        cell.messageText.addGestureRecognizer(tap)

        return cell
    }

    private func getCellIdentifier(index: Int, message: Message, isOutcoming: Bool) -> String {
        let showTime = needShowTime(index, message: message)

        if (isOutcoming && showTime) {
            return "OutcomingTimeCell"
        } else if (isOutcoming && !showTime) {
            return "OutcomingCell"
        } else if (!isOutcoming && showTime) {
            return "IncomingTimeCell"
        } else {
            return "IncomingCell"
        }
    }

    private func needShowTime(index: Int, message: Message) -> Bool {
        if (index == 0) {
            return true
        } else {
            let prevMessage = talk.messages[index - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSinceDate(prevMessage.timestamp))

            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                return true
            }
        }

        return false
    }

    func isOutcomingMessageCell(index: Int, message: Message) -> Bool {
        fatalError("This method must be overridden")
    }

    func messageTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let message = label.tagObject as! Message

        messageTappedComputer?.messageTapped(message)
    }

    func scrollTableToEarlier(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
    }

    func scrollTableToBottom() {
        if (talk.messages.count != 0) {
            let indexPath = NSIndexPath(forItem: talk.messages.count - 1, inSection: 0)
            scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
}
