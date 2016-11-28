import Foundation
import UIKit

class FixedTileView: TileView {
    var position: Int

    required init(coder aDecoder: NSCoder) {
        fatalError("use init(letter:, sideLength:, position:")
    }

    init(letter: Character, sideLength: CGFloat, position: Int) {
        self.position = position

        super.init(letter: letter, sideLength: sideLength)
    }
}
