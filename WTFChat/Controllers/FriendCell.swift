//
//  FriendCell.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet private weak var friendImage: UIImageView!
    
    @IBOutlet private weak var lastMessageAuthorImage: UIImageView!
    @IBOutlet private weak var lastMessageAuthorImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var lastMessageAuthorImageMargin: NSLayoutConstraint!
    
    @IBOutlet private weak var friendName: UILabel!
    
    @IBOutlet private weak var lastMessage: RoundedLabel!
    
    @IBOutlet private weak var lastMessageTime: UILabel!
    
    @IBOutlet private weak var cipheredView: UIView!
    @IBOutlet private weak var cipheredNum: RoundedLabel!
    @IBOutlet private weak var cipheredNumWidthConstraint: NSLayoutConstraint!
    
    var message: Message?

    func updateTalk(talk: Talk) {
        initStyle()
        
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
        
        let jsqFriendImage = avatarService.getAvatarImage(talk.getFriendLogin(),
            diameter: UInt(friendImage.bounds.height))
        
        friendImage.image = jsqFriendImage.avatarImage
    }
    
    private func initStyle() {
        friendImage.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage.layer.cornerRadius = friendImage.frame.size.width/2
        friendImage.clipsToBounds = true
        
        self.selectionStyle = .None;
        
        cipheredNum.setMargins(0, left: 4, bottom: 0, right: 4)
        cipheredNum.layer.masksToBounds = true;
        cipheredNum.layer.cornerRadius = 6.0;
        cipheredNum.textColor = UIColor.whiteColor()
        cipheredNum.font = UIFont(name: lastMessage.font.fontName, size: 10)
        cipheredNum.numberOfLines = 1
        
        lastMessage.layer.masksToBounds = true;
        lastMessage.layer.cornerRadius = 8.0;
        lastMessage.textColor = UIColor.whiteColor()
        lastMessage.font = UIFont(name: lastMessage.font.fontName, size: 13)
        lastMessage.numberOfLines = 1
    }
    
    private func hideLastAuthorImage() {
        lastMessageAuthorImageWidth.constant = 0
        lastMessageAuthorImageMargin.constant = 0
    }
    
    private func updateLastAuthorImage(name: String) {
        let jsqAuthorImage = avatarService.getAvatarImage(name,
            diameter: UInt(lastMessageAuthorImage.bounds.height))
        
        lastMessageAuthorImage.image = jsqAuthorImage.avatarImage
        
        lastMessageAuthorImageWidth.constant = 30
        lastMessageAuthorImageMargin.constant = 4
    }
    
    private func updateCiphered(talk: Talk) {
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
    
    private func setEmptyCiphered() {
        cipheredNum.text = ""
        cipheredNum.hidden = true
        cipheredNum.layer.backgroundColor = UIColor.whiteColor().CGColor
        cipheredNumWidthConstraint.constant = 0
    }
    
    private func setEmptyMessage() {
        lastMessage.text = ""
        lastMessage.layer.backgroundColor = UIColor.whiteColor().CGColor
        lastMessageTime.text = ""
    }
    
    private func updateMessage(message: Message) {
        lastMessageTime.text = timeService.parseTime(message.timestamp).string
        
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
