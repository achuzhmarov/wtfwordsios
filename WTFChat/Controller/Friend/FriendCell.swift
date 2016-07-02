//
//  FriendCell.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)
    private let avatarService: AvatarService = serviceLocator.get(AvatarService)
    private let timeService: TimeService = serviceLocator.get(TimeService)

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
    
    var message: RemoteMessage?

    private func initStyle() {
        friendImage.layer.borderColor = UIColor.whiteColor().CGColor
        friendImage.layer.cornerRadius = friendImage.bounds.width/2
        friendImage.clipsToBounds = true

        self.selectionStyle = .None;

        cipheredNum.setMargins(0, left: 4, bottom: 0, right: 4)
        cipheredNum.layer.cornerRadius = 6.0;
        cipheredNum.textColor = UIColor.whiteColor()
        cipheredNum.font = UIFont(name: lastMessage.font.fontName, size: 10)
        cipheredNum.numberOfLines = 1

        lastMessage.layer.cornerRadius = 8.0;
        lastMessage.textColor = UIColor.whiteColor()
        lastMessage.font = UIFont(name: lastMessage.font.fontName, size: 13)
        lastMessage.numberOfLines = 1

        friendName.adjustsFontSizeToFitWidth = true
    }

    func updateTalk(talk: FriendTalk) {
        initStyle()

        if (talk.isSingleMode) {
            friendName.text = currentUserService.getFriendLogin(talk).capitalizedString
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
    
    private func hideLastAuthorImage() {
        lastMessageAuthorImageWidth.constant = 0
        lastMessageAuthorImageMargin.constant = 0
    }
    
    private func updateLastAuthorImage(name: String) {
        lastMessageAuthorImage.image = avatarService.getImage(name,
            diameter: UInt(lastMessageAuthorImage.bounds.height))
        
        lastMessageAuthorImageWidth.constant = 30
        lastMessageAuthorImageMargin.constant = 4
    }
    
    private func updateCiphered(talk: FriendTalk) {
        cipheredNumWidthConstraint.constant = 13
        cipheredNum.hidden = false
        cipheredNum.text = " "
        
        if (talk.cipheredNum > 0) {
            if (talk.cipheredNum > 9) {
                cipheredNum.text = "9"
            } else {
                cipheredNum.text = String(talk.cipheredNum)
            }

            cipheredNum.addGradientToLabel(Gradient.Ciphered)
            //cipheredNum.layer.backgroundColor = Color.Ciphered.CGColor
        } else if (talk.decipherStatus == .Success) {
            cipheredNum.addGradientToLabel(Gradient.Success)
            //cipheredNum.layer.backgroundColor = Color.Success.CGColor
        } else if (talk.decipherStatus == .Failed) {
            cipheredNum.addGradientToLabel(Gradient.Failed)
            //cipheredNum.layer.backgroundColor = Color.Failed.CGColor
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
    
    private func updateMessage(message: RemoteMessage) {
        lastMessageTime.text = timeService.parseTime(message.timestamp).string

        if (message.author == currentUserService.getUserLogin()) {
            lastMessage.text = message.clearText()
        } else {
            lastMessage.text = message.text()
        }

        switch message.getMessageStatus() {
            case .Success:
                lastMessage.addGradientToLabel(Gradient.Success)
                //lastMessage.layer.backgroundColor = Color.Success.CGColor
            case .Failed:
                lastMessage.addGradientToLabel(Gradient.Failed)
                //lastMessage.layer.backgroundColor = Color.Failed.CGColor
            case .Ciphered:
                lastMessage.addGradientToLabel(Gradient.Ciphered)
                //lastMessage.layer.backgroundColor = Color.Ciphered.CGColor
        }
    }
}
