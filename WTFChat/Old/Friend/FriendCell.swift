//
//  FriendCell.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let avatarService: AvatarService = serviceLocator.get(AvatarService.self)
    fileprivate let timeService: TimeService = serviceLocator.get(TimeService.self)

    @IBOutlet fileprivate weak var friendImage: UIImageView!
    
    @IBOutlet fileprivate weak var lastMessageAuthorImage: UIImageView!
    @IBOutlet fileprivate weak var lastMessageAuthorImageWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var lastMessageAuthorImageMargin: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var friendName: UILabel!
    
    @IBOutlet fileprivate weak var lastMessage: RoundedLabel!
    
    @IBOutlet fileprivate weak var lastMessageTime: UILabel!
    
    @IBOutlet fileprivate weak var cipheredView: UIView!
    @IBOutlet fileprivate weak var cipheredNum: RoundedLabel!
    @IBOutlet fileprivate weak var cipheredNumWidthConstraint: NSLayoutConstraint!
    
    var message: RemoteMessage?

    fileprivate func initStyle() {
        friendImage.layer.borderColor = UIColor.white.cgColor
        friendImage.layer.cornerRadius = friendImage.bounds.width/2
        friendImage.clipsToBounds = true

        self.selectionStyle = .none;

        cipheredNum.setMargins(0, left: 4, bottom: 0, right: 4)
        cipheredNum.layer.cornerRadius = 6.0;
        cipheredNum.textColor = UIColor.white
        cipheredNum.font = UIFont.init(name: lastMessage.font.fontName, size: 10)
        cipheredNum.numberOfLines = 1

        lastMessage.layer.cornerRadius = 8.0;
        lastMessage.textColor = UIColor.white
        lastMessage.font = UIFont.init(name: lastMessage.font.fontName, size: 13)
        lastMessage.numberOfLines = 1

        friendName.adjustsFontSizeToFitWidth = true
    }

    func updateTalk(_ talk: FriendTalk) {
        initStyle()

        if (talk.isSingleMode) {
            friendName.text = currentUserService.getFriendLogin(talk).capitalized
        } else {
            let friendInfo = currentUserService.getFriendInfoByTalk(talk)
            friendName.text = friendInfo!.getDisplayName()
        }
        
        if let message = talk.lastMessage {
            updateCiphered(talk)
            updateMessage(message)
            
            if (message.author != currentUserService.getFriendLogin(talk)) {
                updateLastAuthorImage(message.author)
            } else {
                hideLastAuthorImage()
            }
        } else {
            setEmptyMessage()
            setEmptyCiphered()
            hideLastAuthorImage()
        }

        //TODO AWKARD!!!
        friendImage.image = avatarService.getImage(currentUserService.getFriendLogin(talk),
            diameter: UInt(friendImage.bounds.height))
    }
    
    fileprivate func hideLastAuthorImage() {
        lastMessageAuthorImageWidth.constant = 0
        lastMessageAuthorImageMargin.constant = 0
    }
    
    fileprivate func updateLastAuthorImage(_ name: String) {
        lastMessageAuthorImage.image = avatarService.getImage(name,
            diameter: UInt(lastMessageAuthorImage.bounds.height))
        
        lastMessageAuthorImageWidth.constant = 30
        lastMessageAuthorImageMargin.constant = 4
    }
    
    fileprivate func updateCiphered(_ talk: FriendTalk) {
        cipheredNumWidthConstraint.constant = 13
        cipheredNum.isHidden = false
        cipheredNum.text = " "
        
        if (talk.cipheredNum > 0) {
            if (talk.cipheredNum > 9) {
                cipheredNum.text = "9"
            } else {
                cipheredNum.text = String(talk.cipheredNum)
            }

            cipheredNum.addGradientToLabel(Gradient.Ciphered)
            //cipheredNum.layer.backgroundColor = Color.Ciphered.CGColor
        } else if (talk.decipherStatus == .success) {
            cipheredNum.addGradientToLabel(Gradient.Success)
            //cipheredNum.layer.backgroundColor = Color.Success.CGColor
        } else if (talk.decipherStatus == .failed) {
            cipheredNum.addGradientToLabel(Gradient.Failed)
            //cipheredNum.layer.backgroundColor = Color.Failed.CGColor
        } else {
            setEmptyCiphered()
        }
    }
    
    fileprivate func setEmptyCiphered() {
        cipheredNum.text = ""
        cipheredNum.isHidden = true
        cipheredNum.layer.backgroundColor = UIColor.white.cgColor
        cipheredNumWidthConstraint.constant = 0
    }
    
    fileprivate func setEmptyMessage() {
        lastMessage.text = ""
        lastMessage.layer.backgroundColor = UIColor.white.cgColor
        lastMessageTime.text = ""
    }
    
    fileprivate func updateMessage(_ message: RemoteMessage) {
        lastMessageTime.text = timeService.parseTime(message.timestamp).string

        if (message.author == currentUserService.getUserLogin()) {
            lastMessage.text = message.clearText()
        } else {
            lastMessage.text = message.text()
        }

        switch message.getMessageStatus() {
            case .success:
                lastMessage.addGradientToLabel(Gradient.Success)
                //lastMessage.layer.backgroundColor = Color.Success.CGColor
            case .failed:
                lastMessage.addGradientToLabel(Gradient.Failed)
                //lastMessage.layer.backgroundColor = Color.Failed.CGColor
            case .ciphered:
                lastMessage.addGradientToLabel(Gradient.Ciphered)
                //lastMessage.layer.backgroundColor = Color.Ciphered.CGColor
        }
    }
}
