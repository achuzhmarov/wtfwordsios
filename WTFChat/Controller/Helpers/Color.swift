import Foundation

class Color {
    //static let BACKGROUND = UIColor(netHex:0xEEEEEE)
    //static let HIGHLIGHT_BACKGROUND = UIColor(netHex:0xFFFFFF)

    static let Success = UIColor(netHex:0x3EC303)
    static let Ciphered = UIColor(netHex:0x0092D7)
    static let Failed = UIColor(netHex:0xF26964)
    static let Try = UIColor(netHex:0xEE8D09)
    static let Text = UIColor.whiteColor()
    static let Ignore = UIColor(hue: 240.0 / 360.0, saturation: 0.02, brightness: 0.92, alpha: 1.0)

    static let EasyDark = UIColor(red: 126/255, green: 73/255, blue: 13/255, alpha: 1.0)
    static let EasyMid = UIColor(red: 191/255, green: 121/255, blue: 36/255, alpha: 1.0)
    static let EasyLight = UIColor(red: 247/255, green: 235/255, blue: 222/255, alpha: 1.0)

    static let NormalDark = UIColor(red: 121/255, green: 136/255, blue: 140/255, alpha: 1.0)
    static let NormalMid = UIColor(red: 177/255, green: 194/255, blue: 198/255, alpha: 1.0)
    static let NormalLight = UIColor(red: 244/255, green: 246/255, blue: 245/255, alpha: 1.0)

    static let HardDark = UIColor(red: 0.6, green: 0.5, blue: 0.15, alpha: 1.0)
    static let HardMid = UIColor(red: 0.86, green: 0.73, blue: 0.3, alpha: 1.0)
    static let HardLight = UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 1.0)

    static let CipheredMid = UIColor(red: 18/255, green: 140/255, blue: 220/255, alpha: 1.0)
    static let CipheredDark = UIColor(red: 15/255, green: 105/255, blue: 169/255, alpha: 1.0)

    //static let BackgroundMid = UIColor(red: 214/255, green: 227/255, blue: 243/255, alpha: 1.0)
    //static let BackgroundDark = UIColor(red: 114/255, green: 178/255, blue: 255/255, alpha: 1.0)
    static let BackgroundMid = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let BackgroundDark = UIColor(red: 197/255, green: 227/255, blue: 245/255, alpha: 1.0)

    static let IgnoreMid = UIColor(red: 140/255, green: 144/255, blue: 158/255, alpha: 1.0)
    static let IgnoreDark = UIColor(red: 105/255, green: 107/255, blue: 112/255, alpha: 1.0)

    static func getBorderColorByDifficulty(difficulty: CipherDifficulty) -> UIColor {
        switch difficulty {
            case .Easy:
                return Color.EasyDark
            case .Normal:
                return Color.NormalDark
            case .Hard:
                return Color.HardDark
        }
    }

    static let Background = UIColor(patternImage: UIImage(named: "background")!)
    static let Button = UIImage(named: "button")!
}
