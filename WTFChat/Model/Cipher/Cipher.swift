protocol Cipher {
    func getTextForDecipher(_ word: Word) -> String
}

class CipherHelper {
    class func getNDots(_ n: Int) -> String {
        var result = ""

        for i in 0..<n {
            result = result + "."
        }

        return result
    }
}