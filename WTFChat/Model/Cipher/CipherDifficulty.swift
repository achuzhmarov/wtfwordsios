import Localize_Swift

enum CipherDifficulty : Int, CustomStringConvertible {
    case easy = 0
    case normal
    case hard

    var description : String {
        get {
            switch self {
            case CipherDifficulty.easy:
                return "Easy".localized()
            case CipherDifficulty.normal:
                return "Normal".localized()
            case CipherDifficulty.hard:
                return "Hard".localized()
            }
        }
    }

    static func getAll() -> [CipherDifficulty] {
        return [.easy, .normal, .hard]
    }
}
