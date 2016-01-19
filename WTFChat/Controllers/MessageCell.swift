//
//  MessageCell.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 06/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var messageText: RoundedLabel!
    @IBOutlet weak var timeText: UILabel!
    
    func initStyle() {
        friendImage?.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage?.layer.cornerRadius = friendImage.bounds.width/2
        friendImage?.clipsToBounds = true
        
        self.selectionStyle = .None;
        
        messageText.textColor = FONT_COLOR
        messageText.font = UIFont(name: messageText.font.fontName, size: 16)
        messageText.layer.cornerRadius = 10.0
        messageText.initStyle()
    }
    
    func updateMessage(message: Message, isSingleMode: Bool) {
        initStyle()

        let isOutcoming = (message.author == currentUserService.getUserLogin())
        
        var text = ""
        
        if (isOutcoming) {
            text = message.clearText()
        } else {
            text = message.text()
        }
        
        messageText.text = text
        messageText.tagObject = message
        messageText.sizeToFit()
        
        if (message.deciphered) {
            if (message.countFailed() > 0) {
                messageText.layer.backgroundColor = FAILED_COLOR.CGColor
            } else {
                messageText.layer.backgroundColor = SUCCESS_COLOR.CGColor
            }
        } else {
            messageText.layer.backgroundColor = CIPHERED_COLOR.CGColor
        }
        
        if (!isOutcoming && !isSingleMode) {
            friendImage.image = avatarService.getAvatarImage(message.author,
                diameter: UInt(friendImage.bounds.height))
        } else {
            friendImage?.image = avatarService.getAvatarImage("🙂",
                diameter: UInt(friendImage.bounds.height))
        }
        
        timeText?.attributedText = timeService.parseTime(message.timestamp)
    }
}
