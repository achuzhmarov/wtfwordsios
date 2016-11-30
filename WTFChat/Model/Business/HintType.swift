import Foundation

enum HintType: Int {
    case hint = 0
    case letters
    case solve

    var costInWtfs: Int {
        get {
            switch self {
            case .hint:
                return 1
            case .letters:
                return 1
            case .solve:
                return 3
            }
        }
    }
}
