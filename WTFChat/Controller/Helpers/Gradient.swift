import Foundation

class Gradient {
    private static let StarEasy = [Color.EasyLight.cgColor, Color.EasyMid.cgColor, Color.EasyDark.cgColor]
    private static let StarNormal = [Color.NormalLight.cgColor, Color.NormalMid.cgColor, Color.NormalDark.cgColor]
    private static let StarHard = [Color.HardLight.cgColor, Color.HardMid.cgColor, Color.HardDark.cgColor]

    private static let LevelEasy = [Color.EasyMid.cgColor, Color.EasyDark.cgColor]
    private static let LevelNormal = [Color.NormalMid.cgColor, Color.NormalDark.cgColor]
    private static let LevelHard = [Color.HardMid.cgColor, Color.HardDark.cgColor]

    static let Ciphered = [Color.CipheredLight.cgColor, Color.CipheredDark.cgColor]
    static let Ignored = [Color.IgnoreLight.cgColor, Color.IgnoreDark.cgColor]
    static let Failed = [Color.FailedLight.cgColor, Color.FailedDark.cgColor]
    static let Success = [Color.SuccessLight.cgColor, Color.SuccessDark.cgColor]
    static let Try = [Color.TryLight.cgColor, Color.TryDark.cgColor]

    static let Background = [Color.BackgroundLight.cgColor, Color.BackgroundDark.cgColor]
    static let BackgroundMenu = [Color.BackgroundLight.cgColor, Color.BackgroundMid.cgColor]

    static let Tile = [Color.TileLight.cgColor, Color.TileDark.cgColor]

    static func getStarGradientByDifficulty(_ difficulty: CipherDifficulty) -> [CGColor] {
        switch difficulty {
            case .easy:
                return Gradient.StarEasy
            case .normal:
                return Gradient.StarNormal
            case .hard:
                return Gradient.StarHard
        }
    }

    static func getLevelGradientByDifficulty(_ difficulty: CipherDifficulty) -> [CGColor] {
        switch difficulty {
        case .easy:
            return Gradient.LevelEasy
        case .normal:
            return Gradient.LevelNormal
        case .hard:
            return Gradient.LevelHard
        }
    }
}
