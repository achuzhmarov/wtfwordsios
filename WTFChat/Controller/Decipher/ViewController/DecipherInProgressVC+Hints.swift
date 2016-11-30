import Foundation
import Localize_Swift

extension DecipherInProgressVC: WordTappedComputer {
    func wordTapped(_ word: Word) {
        if (word.type == WordType.new) {
            if (word.wasCloseTry) {
                showCloseTryHintConfirm(word)
            } else if (wtfs > 0) {
                showHintConfirm(word)
            } else {
                showNoHintsDialog()
            }
        } else {
            //do nothing
        }
    }

    func showNoHintsDialog() {
        WTFTwoButtonsAlert.show("WTFs remained: 0".localized(),
                message: "You have used all WTFs. Want to get more?".localized(),
                firstButtonTitle: "Get more".localized()) { () -> Void in

            self.isPaused = true
            self.performSegue(withIdentifier: "getMoreHints", sender: self)
        }
    }

    fileprivate func showHintConfirm(_ word: Word) {
        WTFTwoButtonsAlert.show("WTFs remained:".localized() + " " + String(wtfs),
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

        audioService.playSound("success")

        if (word.wasCloseTry) {
            messageCipherService.decipher(message, hintedWord: word, closeTry: true)
        } else {
            messageCipherService.decipher(message, hintedWord: word)
            updateWtfsUsed(HintType.solve.costInWtfs)
        }

        wordsTableView.updateMessage(message)

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func updateWtfsUsed(_ wtfs: Int) {
        message.wtfUsed += wtfs
        currentUserService.useWtfs(wtfs)
        updateHintsCount()
    }

    func updateHintsCount() {
        wtfs = currentUserService.getUserWtfs() //
    }
}
