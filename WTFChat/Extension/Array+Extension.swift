import Foundation

extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let changeIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            
            if (index != changeIndex) {
                swap(&elements[index], &elements[changeIndex])
            }
        }
        return elements
    }
    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
}