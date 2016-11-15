import Foundation
import Localize_Swift

extension DecipherInProgressByLettersVC: HintComputer {
    func hintTapped(_ word: Word) {
        if (word.type == WordType.new) {
            if (word.wasCloseTry) {
                showCloseTryHintConfirm(word)
            } else if (hints > 0) {
                showHintConfirm(word)
            } else {
                showNoHintsDialog()
            }
        } else {
            //do nothing
        }
    }

    func showNoHintsDialog() {
        WTFTwoButtonsAlert.show("Hints remained: 0".localized(),
                message: "You have used all hints. Want to get more?".localized(),
                firstButtonTitle: "Get more".localized()) { () -> Void in

            self.isPaused = true
            self.performSegue(withIdentifier: "getMoreHints", sender: self)
        }
    }

    fileprivate func showHintConfirm(_ word: Word) {
        WTFTwoButtonsAlert.show("Hints remained:".localized() + " " + String(hints),
                message: "",
                firstButtonTitle: "Use a Hint".localized()) { () -> Void in

            DispatchQueue.main.async(execute: {
                self.useHint(word)
            })
        }
    }

    fileprivate func showCloseTryHintConfirm(_ word: Word) {
        WTFTwoButtonsAlert.show("Open this word?".localized(),
                message: "",
                firstButtonTitle: "Open".localized()) { () -> Void in

            DispatchQueue.main.async(execute: {
                self.useHint(word)
            })
        }
    }

    func useHint(_ word: Word) {
        if (message.getMessageStatus() != .ciphered) {
            return
        }

        audioService.playSound("success")

        if (word.wasCloseTry) {
            messageCipherService.decipher(message, hintedWord: word, closeTry: true)
        } else {
            messageCipherService.decipher(message, hintedWord: word)
            updateHintsUsed()
        }

        wordsTableView.updateMessage(message)

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func updateHintsUsed() {
        message.hintsUsed += 1
        currentUserService.useHints(1)
        updateHintsCount()
    }

    func updateHintsCount() {
        hints = currentUserService.getUserHints() // - message.hintsUsed
    }
}
