import Foundation

class CipherTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
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
}
