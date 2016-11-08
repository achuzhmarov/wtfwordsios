import Foundation

class AvatarService: Service {
    fileprivate var avatarImageCache = [String: [UInt: UIImage]]()

    func getSingleModeImage(_ diameter: UInt) -> UIImage {
        return getImage(Emoji.SMILE_FACE, diameter: diameter)
    }

    func getImage(_ name: String, diameter: UInt) -> UIImage {
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
            initials = name[0...min(2, nameLength - 1)].capitalized
        } else {
            initials = Emoji.SMILE_FACE
        }
        
        let jsqImage = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: initials, backgroundColor: color, textColor: UIColor.black, font: UIFont.systemFont(ofSize: CGFloat(13)), diameter: diameter)
        
        if avatarImageCache[name] != nil {
            avatarImageCache[name]![diameter] = jsqImage?.avatarImage
        } else {
            avatarImageCache[name] = [UInt: UIImage]()
            avatarImageCache[name]![diameter] = jsqImage?.avatarImage
        }
        
        return jsqImage!.avatarImage
    }
}
