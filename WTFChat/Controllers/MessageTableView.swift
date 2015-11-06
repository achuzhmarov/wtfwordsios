//
//  MessageTableViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

protocol MessageTappedComputer {
    func messageTapped(message: Message)
}

class MessageTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    var talk: Talk!
    var messageTappedComputer: MessageTappedComputer?
    
    func updateTalk(talk: Talk) {
        self.talk = talk
        self.reloadData()
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talk.messages.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = getCellIdentifier(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageCell
        
        let message = talk.messages[indexPath.row]
        cell.updateMessage(message)
        
        //cellTapped
        //dismissKeyboard()
        //performSegueWithIdentifier("showDecipher", sender: message)
        
        return cell
    }
    
    private func getCellIdentifier(index: Int) -> String {
        let message = talk.messages[index]
        let isOutcoming = (message.author == userService.getUserLogin())
        var showTime = false
        
        if (index == 0) {
            showTime = true
        } else {
            let prevMessage = self.talk.messages[index - 1]
            let diffSeconds = Int(message.timestamp.timeIntervalSinceDate(prevMessage.timestamp))
            
            if (diffSeconds > INTERVAL_BETWEEN_MESSAGES_TO_SHOW_TOP_TIMESTAMP_IN_SECONDS) {
                showTime = true
            }
        }
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        messageTappedComputer?.messageTapped(talk.messages[indexPath.row])
    }
}