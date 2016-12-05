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

    var tileSide: CGFloat!

    private var screenWidth: CGFloat {
        return self.bounds.size.width
    }

    private var screenHeight: CGFloat {
        return self.bounds.size.height
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

        initHintButton(xOffset: xOffset)
    }

    private func initTwoButtons() {
        let xOffset = (screenWidth - buttonWidth * 2 - xPadding) / 2.0

        initHintButton(xOffset: xOffset)
        initLettersButton(xOffset: xOffset + xPadding + buttonWidth)
    }

    private func initThreeButtons() {
        let xOffset = buttonWidth + xPadding

        initHintButton(xOffset: 0)
        initLettersButton(xOffset: xOffset)
        initSolveButton(xOffset: xOffset * 2)
    }

    private func initHintButton(xOffset: CGFloat) {
        hintButton = createButton(title: HINT_TITLE, xOffset: xOffset)
    }

    private func initLettersButton(xOffset: CGFloat) {
        lettersButton = createButton(title: LETTERS_TITLE, xOffset: xOffset)
    }

    private func initSolveButton(xOffset: CGFloat) {
        solveButton = createButton(title: SOLVE_TITLE, xOffset: xOffset)
    }

    private func createButton(title: String, xOffset: CGFloat) -> GameButton {
        let button = GameButton(frame: CGRect(x: xOffset, y: yPosition, width: buttonWidth, height: tileSide))
        button.setTitle(title.localized(), for: UIControlState())
        button.titleLabel?.font = UIFont(name: button.titleLabel!.font.fontName, size: button.frame.height * 0.4)
        addSubview(button)

        return button
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
