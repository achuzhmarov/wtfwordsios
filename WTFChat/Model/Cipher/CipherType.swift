import Localize_Swift

enum CipherType : Int, CustomStringConvertible {
    case RightCutter = 0
    case LeftCutter
    case Shuffle
    case RandomCutter
    case DoubleCutter

    var description : String {
        get {
            switch self {
            case CipherType.RightCutter:
                return "Right Cutter".localized()
            case CipherType.LeftCutter:
                return "Left Cutter".localized()
            case CipherType.Shuffle:
                return "Shuffle".localized()
            case CipherType.RandomCutter:
                return "Random Cutter".localized()
            case CipherType.DoubleCutter:
                return "Double Cutter".localized()
            }
        }
    }

    static func getAll() -> [CipherType] {
        return [.RightCutter, .LeftCutter, .Shuffle, .RandomCutter, .DoubleCutter]
    }
}