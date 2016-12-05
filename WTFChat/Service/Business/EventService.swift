import Foundation

enum WtfEvent: Int {
    case hint = 0, letters, solve, shake
}

class EventService: Service {
    private let currentUserService: CurrentUserService
    private let guiDataService: GuiDataService
    private let categoryService: SingleModeCategoryService

    private let GOT_HINT_MESSAGE = "Let me introduce you the real power of WTF! You can do almost everything with it. For example, open the next letter! Just use the button 'hint' at the bottom of your screen.";

    private let GOT_LETTERS_MESSAGE = "Congratulations! You have done well so far. How about some new powers?";
    private let GOT_LETTERS_MESSAGE_2 = "You can now see the correct letters for the word. Just use the button 'letters'.";

    private let GOT_SOLVE_MESSAGE = "Wow, you are still playing! Very good! Let me give you one more power than!";
    private let GOT_SOLVE_MESSAGE_2 = "You can now solve the word with just a touch. But be carefull, it will cost you a little more.";

    private let GOT_SHAKE_MESSAGE = "Hey, here is one more cool thing. You can shake your device to clear entered letters! Use it wisely.";

    private let lvlTriggers: [WtfStage: Int] = [
            .beginning: 4,
            .gotHint: 9,
            .gotLetters: 14,
            .gotSolve: 19
    ]

    private let wtfEvents: [WtfStage: WtfEvent] = [
            .beginning: .hint,
            .gotHint: .letters,
            .gotLetters: .solve,
            .gotSolve: .shake
    ]

    init(guiDataService: GuiDataService, categoryService: SingleModeCategoryService, currentUserService: CurrentUserService) {
        self.guiDataService = guiDataService
        self.categoryService = categoryService
        self.currentUserService = currentUserService
    }

    public func eventAwaiting() -> WtfEvent? {
        let wtfStage = guiDataService.getWtfStage()

        switch wtfStage {
            case .firstFailure:
                return .hint
            case .gotShake:
                return nil
            default:
                return getEventIfNeeded(wtfStage)
        }
    }

    private func getEventIfNeeded(_ wtfStage: WtfStage) -> WtfEvent? {
        if let lvlTrigger = lvlTriggers[wtfStage] {
            if isLevelCleared(lvlTrigger) {
                return wtfEvents[wtfStage]
            }
        }

        return nil
    }

    private func isLevelCleared(_ lvlId: Int) -> Bool {
        let rightCutterCategory = categoryService.getCategory(.rightCutter)!

        for lvl in rightCutterCategory.levels {
            if (lvl.id == lvlId) && lvl.cleared {
                return true
            }
        }

        return false
    }

    public func updateWtfStageForEvent(_ event: WtfEvent) {
        switch event {
            case .hint:
                guiDataService.updateWtfStage(.gotHint)
                currentUserService.addWtf(HintType.hint.costInWtf)
            case .letters:
                guiDataService.updateWtfStage(.gotLetters)
                currentUserService.addWtf(HintType.letters.costInWtf)
            case .solve:
                guiDataService.updateWtfStage(.gotSolve)
                currentUserService.addWtf(HintType.solve.costInWtf)
            case .shake:
                guiDataService.updateWtfStage(.gotShake)
        }
    }

    public func showEvent(_ event: WtfEvent, completion: (() -> ())? = nil) {
        switch event {
            case .hint:
                showMessageAlert(GOT_HINT_MESSAGE, completion: completion)
            case .letters:
                showMessageAlert(GOT_LETTERS_MESSAGE, message2: GOT_LETTERS_MESSAGE_2, completion: completion)
            case .solve:
                showMessageAlert(GOT_SOLVE_MESSAGE, message2: GOT_SOLVE_MESSAGE_2, completion: completion)
            case .shake:
                showMessageAlert(GOT_SHAKE_MESSAGE, completion: completion)
        }
    }

    private func showMessageAlert(_ message1: String, message2: String, wtfStage: WtfStage? = nil, completion: (() -> ())? = nil) {
        showMessageAlert(message1) {
            self.showMessageAlert(message2, completion: completion)
        }
    }

    private func showMessageAlert(_ message: String, completion: (() -> ())? = nil) {
        WTFOneButtonAlert.show(message.localized(), message: "", alertButtonAction: completion)
    }
}
