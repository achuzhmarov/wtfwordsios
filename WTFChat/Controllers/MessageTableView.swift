//
//  MessageTableViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol MessageTappedComputer: class {
    func messageTapped(message: Message)
}

let INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS = 10 * 60

class MessageTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var oldMessagesCount = 0
    var talk: Talk!
    weak var messageTappedComputer: MessageTappedComputer?
    
    func updateTalk(talk: Talk) {
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
        
        let cellIdentifier = getCellIdentifier(indexPath.row, message: message)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageCell
        
        cell.updateMessage(message, isSingleMode: talk.isSingleMode)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageTableView.messageTapped(_:)))
        cell.messageText.addGestureRecognizer(tap)
        
        return cell
    }
    
    private func getCellIdentifier(index: Int, message: Message) -> String {
        var isOutcoming: Bool
        
        if (talk.isSingleMode) {
            isOutcoming = (index % 2 == 1)
        } else {
            isOutcoming = (message.author == currentUserService.getUserLogin())
        }
        
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
            let prevMessage = self.talk.messages[index - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSinceDate(prevMessage.timestamp))
            
            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                return true
            }
        }
        
        return false
    }
    
    func messageTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as! RoundedLabel
        let message = label.tagObject as! Message
        
        self.messageTappedComputer?.messageTapped(message)
    }
    
    func scrollTableToEarlier(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        self.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
    }
    
    func scrollTableToBottom() {
        if (self.talk.messages.count != 0) {
            let indexPath = NSIndexPath(forItem: self.talk.messages.count - 1, inSection: 0)
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
}