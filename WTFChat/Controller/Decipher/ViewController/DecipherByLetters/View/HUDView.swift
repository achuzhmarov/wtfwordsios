import UIKit

class HUDView: UIView {

    var hintButton: UIButton!
    var checkButton: UIButton!
    var solveButton: UIButton!

    //this should never be called
    required init(coder aDecoder: NSCoder) {
        fatalError("use init(frame:")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true

        //load the button image
        let buttonImage = UIImage(named: "btn")!

        let screenWidth = self.bounds.size.width
        let yPosition = CGFloat(20)
        let xPadding = (screenWidth - 3 * buttonImage.size.width) / 2
        let xOffset = buttonImage.size.width + xPadding

        self.hintButton = UIButton(type: .custom)
        hintButton.setTitle("hint", for: UIControlState())
        hintButton.titleLabel?.font = FontHUD
        hintButton.setBackgroundImage(buttonImage, for: UIControlState())
        hintButton.frame = CGRect(x: 0, y: yPosition, width: buttonImage.size.width, height: buttonImage.size.height)
        hintButton.alpha = 0.8
        self.addSubview(hintButton)

        self.checkButton = UIButton(type: .custom)
        checkButton.setTitle("check", for: UIControlState())
        checkButton.titleLabel?.font = FontHUD
        checkButton.setBackgroundImage(buttonImage, for: UIControlState())
        checkButton.frame = CGRect(x: xOffset, y: yPosition, width: buttonImage.size.width, height: buttonImage.size.height)
        checkButton.alpha = 0.8
        self.addSubview(checkButton)

        self.solveButton = UIButton(type: .custom)
        solveButton.setTitle("solve", for: UIControlState())
        solveButton.titleLabel?.font = FontHUD
        solveButton.setBackgroundImage(buttonImage, for: UIControlState())
        solveButton.frame = CGRect(x: xOffset * 2, y: yPosition, width: buttonImage.size.width, height: buttonImage.size.height)
        solveButton.alpha = 0.8
        self.addSubview(solveButton)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //1 let touches through and only catch the ones on buttons
        let hitView = super.hitTest(point, with: event)

        //2
        if hitView is UIButton {
            return hitView
        }

        //3
        return nil
    }

}
