import Foundation
import UIKit

protocol TileDragDelegateProtocol {
    func tileView(_ tileView: TileView, didDragToPoint: CGPoint)
}

class TileView: BorderedButton {
//class TileView: UIImageView {
    var letter: Character

    var isMatched: Bool = false
    var isPlaced: Bool = false
    var placedOnTarget: TargetView?
    var isFixed: Bool = false

    fileprivate var xOffset: CGFloat = 0.0
    fileprivate var yOffset: CGFloat = 0.0

    var dragDelegate: TileDragDelegateProtocol?

    fileprivate var tempTransform: CGAffineTransform = CGAffineTransform.identity

    var originalCenter: CGPoint!

    //4 this should never be called
    required init(coder aDecoder: NSCoder) {
        fatalError("use init(letter:, sideLength:")
    }

    //5 create a new tile for a given letter
    init(letter: Character, sideLength: CGFloat) {
        self.letter = letter

        //the tile background
        let image = UIImage(named: "tile")!
        //let image2 = UIImage(named: "tileNoise")!

        //superclass initializer
        //references to superview's "self" must take place after super.init
        //super.init(image: image)
        //super.init(image: image2)
        super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))

        self.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)

        //6 resize the tile
        let scale = sideLength / image.size.width

        //add a letter on top
        let letterLabel = UILabel(frame: self.bounds)
        letterLabel.textAlignment = NSTextAlignment.center
        letterLabel.textColor = UIColor.white
        letterLabel.backgroundColor = UIColor.clear
        letterLabel.text = String(letter).uppercased()
        letterLabel.font = UIFont(name: "Verdana-Bold", size: 78.0 * scale)
        self.addSubview(letterLabel)

        self.isUserInteractionEnabled = true

        //create the tile shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        self.layer.shadowRadius = 15.0
        self.layer.masksToBounds = false

        let path = UIBezierPath(rect: self.bounds)
        self.layer.shadowPath = path.cgPath

        updateBackground()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFixed) {
            return
        }

        self.layer.shadowOpacity = 0.8
        tempTransform = self.transform
        self.transform = self.transform.scaledBy(x: 1.2, y: 1.2)

        self.superview?.bringSubview(toFront: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (isFixed) {
            return
        }

        self.transform = tempTransform

        dragDelegate?.tileView(self, didDragToPoint: self.center)
        self.layer.shadowOpacity = 0.0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent!) {
        if (isFixed) {
            return
        }

        self.transform = tempTransform
        self.layer.shadowOpacity = 0.0
    }

    func updateBackground() {
        if (self.isFixed) {
            self.updateGradient(Gradient.Success)
        } else {
            self.updateGradient(Gradient.Tile)
        }
    }
}
