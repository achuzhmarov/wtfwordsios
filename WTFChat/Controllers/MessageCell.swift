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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        friendImage?.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage?.layer.cornerRadius = friendImage.frame.size.width/2
        friendImage?.clipsToBounds = true
        
        self.selectionStyle = .None;
        
        messageText.layer.masksToBounds = true
        messageText.layer.cornerRadius = 10.0
        messageText.textColor = UIColor.whiteColor()
        messageText.font = UIFont(name: messageText.font.fontName, size: 17)
        messageText.numberOfLines = 0
    }
    
    func updateMessage(message: Message) {
        messageText.textColor = FONT_COLOR
        let isOutcoming = (message.author == userService.getUserLogin())
        
        var text = ""
        
        if (isOutcoming) {
            text = message.clearText()
        } else {
            text = message.text()
        }
        
        messageText.text = text
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
        
        if (!isOutcoming) {
            friendImage.image = avatarService.getAvatarImage(message.author,
                diameter: UInt(friendImage.bounds.height)).avatarImage
        }
        
        timeText?.text = timeService.parseTime(message.timestamp).string
    }
}
