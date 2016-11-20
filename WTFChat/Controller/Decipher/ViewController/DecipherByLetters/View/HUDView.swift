import UIKit

class HUDView: UIView {

    var hintButton: UIButton!
    var checkButton: UIButton!
    var solveButton: UIButton!

    //load the button image
    private let buttonImage = UIImage(named: "btn")!

    //this should never be called
    required init(coder aDecoder: NSCoder) {
        fatalError("use init(frame:")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true

        let screenWidth = self.bounds.size.width
        let screenHeight = self.bounds.size.height
        let tileSide = ceil(screenWidth / CGFloat(MaxLettersPerRow)) - TileMargin
        let buttonWidth: CGFloat = (screenWidth * 0.9) / 3

        let yPosition = screenHeight - tileSide
        let xPadding = (screenWidth - 3 * buttonWidth) / 2
        let xOffset = buttonWidth + xPadding

        self.hintButton = GameButton(frame: CGRect(x: 0, y: yPosition, width: buttonWidth, height: tileSide))
        hintButton.setTitle("hint", for: UIControlState())
        setStyleForButton(hintButton)
        self.addSubview(hintButton)

        self.checkButton = GameButton(frame: CGRect(x: xOffset, y: yPosition, width: buttonWidth, height: tileSide))
        checkButton.setTitle("letters", for: UIControlState())
        setStyleForButton(checkButton)
        self.addSubview(checkButton)

        self.solveButton = GameButton(frame: CGRect(x: xOffset * 2, y: yPosition, width: buttonWidth, height: tileSide))
        solveButton.setTitle("solve", for: UIControlState())
        setStyleForButton(solveButton)
        self.addSubview(solveButton)
    }

    private func setStyleForButton(_ button: UIButton) {
        //button.titleLabel?.font = FontHUD
        //button.titleLabel?.numberOfLines = 1
        //button.titleLabel?.adjustsFontSizeToFitWidth = true
        //button.titleLabel?.lineBreakMode = .byClipping
        //button.setBackgroundImage(buttonImage, for: UIControlState())
        //button.alpha = 0.8
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
