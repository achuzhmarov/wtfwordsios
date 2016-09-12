import Localize_Swift

enum CipherDifficulty : Int, CustomStringConvertible {
    case Easy = 0
    case Normal
    case Hard

    var description : String {
        get {
            switch self {
            case CipherDifficulty.Easy:
                return "Easy".localized()
            case CipherDifficulty.Normal:
                return "Normal".localized()
            case CipherDifficulty.Hard:
                return "Hard".localized()
            }
        }
    }

    static func getAll() -> [CipherDifficulty] {
        return [.Easy, .Normal, .Hard]
    }
}