//
//  FriendCell.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet weak var friendImage: UIImageView!
    
    @IBOutlet weak var lastMessageAuthorImage: UIImageView!
    @IBOutlet weak var lastMessageAuthorImageWidth: NSLayoutConstraint!
    @IBOutlet weak var lastMessageAuthorImageMargin: NSLayoutConstraint!
    
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var lastMessage: RoundedLabel!
    
    @IBOutlet weak var lastMessageTime: UILabel!
    
    @IBOutlet weak var cipheredView: UIView!
    @IBOutlet weak var cipheredNum: RoundedLabel!
    @IBOutlet weak var cipheredNumWidthConstraint: NSLayoutConstraint!
    
    var message: Message?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        friendImage.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage.layer.cornerRadius = friendImage.frame.size.width/2
        friendImage.clipsToBounds = true
        
        self.selectionStyle = .None;
        
        cipheredNum.setMargins(0, left: 4, bottom: 0, right: 4)
        cipheredNum.layer.masksToBounds = true;
        cipheredNum.textColor = UIColor.whiteColor()
        cipheredNum.font = UIFont(name: lastMessage.font.fontName, size: 10)
        
        lastMessage.layer.masksToBounds = true;
        lastMessage.layer.cornerRadius = 8.0;
        lastMessage.textColor = UIColor.whiteColor()
        lastMessage.font = UIFont(name: lastMessage.font.fontName, size: 13)
    }

    func updateTalk(talk: Talk) {
        /*if (talk.hasUnread || talk.getFriendLogin() == "Nadin") {
            cipheredView.backgroundColor = HIGHLIGHT_BACKGROUND_COLOR
            self.backgroundColor = HIGHLIGHT_BACKGROUND_COLOR
            cipheredNum.layer.backgroundColor = HIGHLIGHT_BACKGROUND_COLOR.CGColor
            lastMessage.layer.backgroundColor = HIGHLIGHT_BACKGROUND_COLOR.CGColor
        } else {
            cipheredView.backgroundColor = BACKGROUND_COLOR
            self.backgroundColor = BACKGROUND_COLOR
            cipheredNum.layer.backgroundColor = BACKGROUND_COLOR.CGColor
            lastMessage.layer.backgroundColor = BACKGROUND_COLOR.CGColor
        }*/
        
        friendName.text = talk.getFriendLogin().capitalizedString
        
        if let message = talk.lastMessage {
            updateCiphered(talk)
            updateMessage(message)
            
            if (message.author != talk.getFriendLogin()) {
                updateLastAuthorImage(message.author)
            } else {
                hideLastAuthorImage()
            }
        } else {
            setEmptyMessage()
            setEmptyCiphered()
            hideLastAuthorImage()
        }
        
        let jsqFriendImage = userService.getAvatarImage(talk.getFriendLogin(),
            diameter: UInt(friendImage.bounds.height))
        
        friendImage.image = jsqFriendImage.avatarImage
    }
    
    func hideLastAuthorImage() {
        lastMessageAuthorImageWidth.constant = 0
        lastMessageAuthorImageMargin.constant = 0
    }
    
    func updateLastAuthorImage(name: String) {
        let jsqAuthorImage = userService.getAvatarImage(name,
            diameter: UInt(lastMessageAuthorImage.bounds.height))
        
        lastMessageAuthorImage.image = jsqAuthorImage.avatarImage
        
        lastMessageAuthorImageWidth.constant = 30
        lastMessageAuthorImageMargin.constant = 4
    }
    
    func updateCiphered(talk: Talk) {
        cipheredNum.layer.cornerRadius = cipheredNum.bounds.size.height/2;
        cipheredNumWidthConstraint.constant = 13
        cipheredNum.hidden = false
        cipheredNum.text = " "
        
        if (talk.cipheredNum > 0) {
            if (talk.cipheredNum > 9) {
                cipheredNum.text = "9"
            } else {
                cipheredNum.text = String(talk.cipheredNum)
            }
            
            cipheredNum.layer.backgroundColor = CIPHERED_COLOR.CGColor
        } else if (talk.decipherStatus == .Success) {
            cipheredNum.layer.backgroundColor = SUCCESS_COLOR.CGColor
        } else if (talk.decipherStatus == .Failed) {
            cipheredNum.layer.backgroundColor = FAILED_COLOR.CGColor
        } else {
            setEmptyCiphered()
        }
    }
    
    func setEmptyCiphered() {
        cipheredNum.text = ""
        cipheredNum.hidden = true
        cipheredNum.layer.backgroundColor = UIColor.whiteColor().CGColor
        cipheredNumWidthConstraint.constant = 0
    }
    
    func setEmptyMessage() {
        lastMessage.text = ""
        lastMessage.layer.backgroundColor = UIColor.whiteColor().CGColor
        lastMessageTime.text = ""
    }
    
    func updateMessage(message: Message) {
        let formatter = NSDateFormatter()
        let now = NSDate()
        
        if (now.getYear() == message.timestamp.getYear()) {
            if (now.getMonth() == message.timestamp.getMonth() &&
                now.getDay() == message.timestamp.getDay()) {
                    
                formatter.dateFormat = "HH:mm"
            } else {
                formatter.dateFormat = "dd.MM HH:mm"
            }
        } else {
            formatter.dateFormat = "dd.MM.yy HH:mm"
        }
        
        lastMessageTime.text = formatter.stringFromDate(message.timestamp)
        
        lastMessage.text = message.text()
        
        if (message.deciphered) {
            if (message.countFailed() > 0) {
                lastMessage.layer.backgroundColor = FAILED_COLOR.CGColor
            } else {
                lastMessage.layer.backgroundColor = SUCCESS_COLOR.CGColor
            }
        } else {
            lastMessage.layer.backgroundColor = CIPHERED_COLOR.CGColor
        }
    }
}
