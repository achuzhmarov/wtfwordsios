import Foundation

class Gradient {
    private static let StarEasy = [Color.EasyLight.CGColor, Color.EasyMid.CGColor, Color.EasyDark.CGColor]
    private static let StarNormal = [Color.NormalLight.CGColor, Color.NormalMid.CGColor, Color.NormalDark.CGColor]
    private static let StarHard = [Color.HardLight.CGColor, Color.HardMid.CGColor, Color.HardDark.CGColor]

    private static let LevelEasy = [Color.EasyMid.CGColor, Color.EasyDark.CGColor]
    private static let LevelNormal = [Color.NormalMid.CGColor, Color.NormalDark.CGColor]
    private static let LevelHard = [Color.HardMid.CGColor, Color.HardDark.CGColor]

    static let Ciphered = [Color.CipheredLight.CGColor, Color.CipheredDark.CGColor]
    static let Ignored = [Color.IgnoreLight.CGColor, Color.IgnoreDark.CGColor]
    static let Failed = [Color.FailedLight.CGColor, Color.FailedDark.CGColor]
    static let Success = [Color.SuccessLight.CGColor, Color.SuccessDark.CGColor]
    static let Try = [Color.TryLight.CGColor, Color.TryDark.CGColor]

    static let Background = [Color.BackgroundLight.CGColor, Color.BackgroundDark.CGColor]
    static let BackgroundMenu = [Color.BackgroundLight.CGColor, Color.BackgroundMid.CGColor]

    static func getStarGradientByDifficulty(difficulty: CipherDifficulty) -> [CGColor] {
        switch difficulty {
            case .Easy:
                return Gradient.StarEasy
            case .Normal:
                return Gradient.StarNormal
            case .Hard:
                return Gradient.StarHard
        }
    }

    static func getLevelGradientByDifficulty(difficulty: CipherDifficulty) -> [CGColor] {
        switch difficulty {
        case .Easy:
            return Gradient.LevelEasy
        case .Normal:
            return Gradient.LevelNormal
        case .Hard:
            return Gradient.LevelHard
        }
    }
}
