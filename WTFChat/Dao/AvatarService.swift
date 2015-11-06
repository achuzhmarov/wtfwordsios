//
//  AvatarImageService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 05/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let avatarService = AvatarService()

class AvatarService {
    var avatarImageCache = [String: [UInt: JSQMessagesAvatarImage]]()
    
    func getAvatarImage(name: String, diameter: UInt) -> JSQMessagesAvatarImage {
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
        
        let initials : String? = name[0...min(2, nameLength)].capitalizedString
        
        let image = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        if avatarImageCache[name] != nil {
            avatarImageCache[name]![diameter] = image
        } else {
            avatarImageCache[name] = [UInt: JSQMessagesAvatarImage]()
            avatarImageCache[name]![diameter] = image
        }
        
        return image
    }
}