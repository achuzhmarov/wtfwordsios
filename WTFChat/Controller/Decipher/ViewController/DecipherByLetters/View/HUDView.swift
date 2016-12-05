import UIKit
import Localize_Swift

class HUDView: UIView {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)

    var hintButton: UIButton?
    var lettersButton: UIButton?
    var solveButton: UIButton?

    //load the button image
    private let buttonImage = UIImage(named: "btn")!

    private let HINT_TITLE = "hint"
    private let LETTERS_TITLE = "letters"
    private let SOLVE_TITLE = "solve"

    private var screenWidth: CGFloat {
        return self.bounds.size.width
    }

    private var screenHeight: CGFloat {
        return self.bounds.size.height
    }

    private var tileSide: CGFloat {
        return ceil(screenWidth / CGFloat(MaxLettersPerRow)) - TileMargin
    }

    private var buttonWidth: CGFloat {
        return (screenWidth * 0.95) / 3.0
    }

    private var yPosition: CGFloat {
        return screenHeight - tileSide
    }

    private var xPadding: CGFloat {
        return (screenWidth - 3 * buttonWidth) / 2.0
    }

    //this should never be called
    required init(coder aDecoder: NSCoder) {
        fatalError("use init(frame:")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    private func initialize() {
        self.isUserInteractionEnabled = true

        switch guiDataService.getWtfStage() {
            case .beginning, .firstFailure:
                 //do nothing
                 return
            case .gotHint:
                initOneButton()
            case .gotLetters:
                initTwoButtons()
            default:
                initThreeButtons()
        }
    }

    private func initOneButton() {
        let xOffset = (screenWidth - buttonWidth) / 2.0

        initHintButton(x: xOffset)
    }

    private func initTwoButtons() {
        let xOffset = (screenWidth - buttonWidth * 2 - xPadding) / 2.0

        initHintButton(x: xOffset)
        initLettersButton(x: xOffset + xPadding + buttonWidth)
    }

    private func initThreeButtons() {
        let xOffset = buttonWidth + xPadding

        initHintButton(x: 0)
        initLettersButton(x: xOffset)
        initSolveButton(x: xOffset * 2)
    }

    private func initHintButton(x: CGFloat) {
        self.hintButton = GameButton(frame: CGRect(x: x, y: yPosition, width: buttonWidth, height: tileSide))
        hintButton!.setTitle(HINT_TITLE.localized(), for: UIControlState())
        self.addSubview(hintButton!)
    }

    private func initLettersButton(x: CGFloat) {
        self.lettersButton = GameButton(frame: CGRect(x: x, y: yPosition, width: buttonWidth, height: tileSide))
        lettersButton!.setTitle(LETTERS_TITLE.localized(), for: UIControlState())
        self.addSubview(lettersButton!)
    }

    private func initSolveButton(x: CGFloat) {
        self.solveButton = GameButton(frame: CGRect(x: x, y: yPosition, width: buttonWidth, height: tileSide))
        solveButton!.setTitle(SOLVE_TITLE.localized(), for: UIControlState())
        self.addSubview(solveButton!)
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

    func update() {
        clear()
        initialize()
    }

    private func clear() {
        hintButton?.removeFromSuperview()
        hintButton = nil

        lettersButton?.removeFromSuperview()
        lettersButton = nil

        solveButton?.removeFromSuperview()
        solveButton = nil
    }
}
