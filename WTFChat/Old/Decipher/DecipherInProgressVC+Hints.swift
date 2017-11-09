/*import Foundation
import Localize_Swift

extension DecipherInProgressVC: WordTappedComputer {
    func wordTapped(_ word: Word) {
        let wtf = currentUserService.getUserWtf()

        if (word.type == WordType.new) {
            if (word.wasCloseTry) {
                showCloseTryHintConfirm(word)
            } else if (wtf > 0) {
                showHintConfirm(word, wtf: wtf)
            } else {
                showNoHintsDialog()
            }
        } else {
            //do nothing
        }
    }

    func showNoHintsDialog() {
        WTFTwoButtonsAlert.show("WTF remained: 0".localized(),
                message: "You have used all WTF. Want to get more?".localized(),
                firstButtonTitle: "Get more".localized()) { () -> Void in

            self.isPaused = true
            self.performSegue(withIdentifier: "getMoreWtf", sender: self)
        }
    }

    fileprivate func showHintConfirm(_ word: Word, wtf: Int) {
        WTFTwoButtonsAlert.show("WTF remained:".localized() + " " + String(wtf),
                message: "",
                firstButtonTitle: "Use a WTF".localized()) { () -> Void in

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

        audioService.playSound(.success)

        if (word.wasCloseTry) {
            messageCipherService.decipher(message, hintedWord: word, closeTry: true)
        } else {
            messageCipherService.decipher(message, hintedWord: word)
            updateWtfUsed(HintType.solve.costInWtf)
        }

        wordsTableView.updateMessage(message)

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func updateWtfUsed(_ wtf: Int) {
        message.wtfUsed += wtf
        currentUserService.useWtf(wtf)
    }
}
*/