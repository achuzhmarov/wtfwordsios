import Foundation

extension DecipherViewController: HintComputer {
    func calcInitialHints() {
        hints = currentUserService.getUserHints() - message.hintsUsed
    }

    @IBAction func hintsBought(segue:UIStoryboardSegue) {
        hints = currentUserService.getUserHints() - message.hintsUsed
    }

    //HintComputer delegate
    func hintTapped(word: Word) {
        if (isOvered) {
            changeCipherStateForViewOnly()
            return
        }

        if (word.type == WordType.New) {
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
        WTFTwoButtonsAlert.show("Hints remained: 0",
                message: "You have used all hints. Want to get more?",
                firstButtonTitle: "Get more",
                secondButtonTitle: "Cancel",
                viewPresenter: self) { () -> Void in

            self.performSegueWithIdentifier("getMoreHints", sender: self)
        }
    }

    private func showHintConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Hints remained: \(String(hints))",
                message: "",
                firstButtonTitle: "Use a Hint",
                secondButtonTitle: "Cancel",
                viewPresenter: self) { () -> Void in
            self.useHint(word)
        }
    }

    private func showCloseTryHintConfirm(word: Word) {
        WTFTwoButtonsAlert.show("Open this word?",
                message: "",
                firstButtonTitle: "Open",
                secondButtonTitle: "Cancel",
                viewPresenter: self) { () -> Void in
            self.useHint(word)
        }
    }

    func useHint(word: Word) {
        if (isOvered) {
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
        hints = currentUserService.getUserHints() - message.hintsUsed
    }
}
