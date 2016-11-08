import Localize_Swift

enum CipherType : Int, CustomStringConvertible {
    case rightCutter = 0
    case leftCutter
    case shuffle
    case randomCutter
    case doubleCutter

    var description : String {
        get {
            switch self {
            case CipherType.rightCutter:
                return "Right Cutter".localized()
            case CipherType.leftCutter:
                return "Left Cutter".localized()
            case CipherType.shuffle:
                return "Shuffle".localized()
            case CipherType.randomCutter:
                return "Random Cutter".localized()
            case CipherType.doubleCutter:
                return "Double Cutter".localized()
            }
        }
    }

    static func getAll() -> [CipherType] {
        return [.rightCutter, .leftCutter, .shuffle, .randomCutter, .doubleCutter]
    }
}
