import Foundation

extension String
{
    func escapeForUrl() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    
    func isGreater(_ stringToCompare : String) -> Bool
    {
        return self.compare(stringToCompare) == ComparisonResult.orderedDescending
    }
    
    func isLess(_ stringToCompare : String) -> Bool
    {
        return self.compare(stringToCompare) == ComparisonResult.orderedAscending
    }
    
    func removeChars(_ chars: [String]) -> String {
        var result = self
        
        for char in chars {
            result = result.replacingOccurrences(of: char, with: "", options: NSString.CompareOptions.literal, range: nil)
        }
        
        return result
    }
    
    func replace(_ what: String, with: String) -> String {
        return self.replacingOccurrences(of: what, with: with, options: NSString.CompareOptions.literal, range: nil)
    }
    
    subscript (i: Int) -> String {
        let char = self[self.characters.index(self.startIndex, offsetBy: i)]
        return String(char)
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: characters.index(startIndex, offsetBy: r.lowerBound)..<characters.index(startIndex, offsetBy: r.upperBound))
    }
    
    var shuffle:String {
        return String(Array(self.characters).shuffle)
    }

    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex...endIndex]
        }
    }
}
