//
//  AvatarImageService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class AvatarService: Service {
    private var avatarImageCache = [String: [UInt: UIImage]]()

    func getSingleModeImage(diameter: UInt) -> UIImage {
        return getImage(Emoji.SMILE_FACE, diameter: diameter)
    }

    func getImage(name: String, diameter: UInt) -> UIImage {
        if let userAvatars = avatarImageCache[name] {
            if let image = userAvatars[diameter] {
                return image
            }
        }
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        
        var initials : String
        
        if (nameLength != 0) {
            initials = name[0...min(2, nameLength - 1)].capitalizedString
        } else {
            initials = Emoji.SMILE_FACE
        }
        
        let jsqImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        if avatarImageCache[name] != nil {
            avatarImageCache[name]![diameter] = jsqImage.avatarImage
        } else {
            avatarImageCache[name] = [UInt: UIImage]()
            avatarImageCache[name]![diameter] = jsqImage.avatarImage
        }
        
        return jsqImage.avatarImage
    }
}