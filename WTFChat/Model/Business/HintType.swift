import Foundation

enum HintType: Int {
    case hint = 0
    case letters
    case solve

    var costInWtf: Int {
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

    var details: String {
        get {
            switch self {
            case .hint:
                return "Open the next letter"
            case .letters:
                return "Highlight correct letters"
            case .solve:
                return "Solve the word"
            }
        }
    }
}
