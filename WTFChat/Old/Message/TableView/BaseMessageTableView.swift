import Foundation

protocol MessageTappedComputer: class {
    func messageTapped(_ message: Message)
}

class BaseMessageTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    fileprivate final let INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS = 10 * 60

    var talk: Talk!

    weak var messageTappedComputer: MessageTappedComputer?

    func updateTalk(_ talk: Talk) {
        self.talk = talk
        self.reloadData()
    }

    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (talk == nil) {
            return 0
        }

        return talk!.messages.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = talk.messages[indexPath.row]

        var height = 35.5

        if (needShowTime(indexPath.row, message: message)) {
            height += 20
        }

        return CGFloat(height)
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = talk.messages[indexPath.row]

        let isOutcoming = isOutcomingMessageCell(indexPath.row, message: message)
        let cellIdentifier = getCellIdentifier(indexPath.row, message: message, isOutcoming: isOutcoming)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseMessageCell

        cell.updateMessage(message, isOutcoming: isOutcoming)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageTableView.messageTapped(_:)))
        cell.messageText.addGestureRecognizer(tap)

        return cell
    }

    fileprivate func getCellIdentifier(_ index: Int, message: Message, isOutcoming: Bool) -> String {
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

    fileprivate func needShowTime(_ index: Int, message: Message) -> Bool {
        if (index == 0) {
            return true
        } else {
            let prevMessage = talk.messages[index - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSince(prevMessage.timestamp as Date))

            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                return true
            }
        }

        return false
    }

    func isOutcomingMessageCell(_ index: Int, message: Message) -> Bool {
        fatalError("This method must be overridden")
    }

    func messageTapped(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let message = label.tagObject as! Message

        messageTappedComputer?.messageTapped(message)
    }

    func scrollTableToEarlier(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        scrollToRow(at: indexPath, at: .top, animated: false)
    }

    func scrollTableToBottom() {
        if (talk.messages.count != 0) {
            let indexPath = IndexPath(item: talk.messages.count - 1, section: 0)
            scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}
