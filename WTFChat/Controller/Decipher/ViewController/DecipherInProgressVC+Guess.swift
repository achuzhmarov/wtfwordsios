import Foundation

extension DecipherInProgressVC: UITextFieldDelegate {

    //delegate enterPressed for guessField
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        tryButtonPressed(tryButton)
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {   //delegate method
        UIView.setAnimationsEnabled(false)
    }

    @IBAction func guessTextChanged(sender: AnyObject) {
        if (guessTextField.text?.characters.count > 0) {
            tryButton.enabled = true
        } else {
            tryButton.enabled = false
        }
    }

    @IBAction func tryButtonPressed(sender: AnyObject) {
        if (guessTextField.text!.characters.count > 1024) {
            WTFOneButtonAlert.show("Too many characters",
                    message: "Your guess should be less than 1024 characters",
                    firstButtonTitle: "Ok")

            return
        }

        messageCipherService.decipher(message, guessText: guessTextField.text!)

        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }

        wordsTableView.updateMessage(message, tries: guessWords)
        guessTextField.text = ""
        tryButton.enabled = false

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        UIView.setAnimationsEnabled(true)

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = keyboardFrame.size.height
        })
    }

    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = 0
        })
    }

    func dismissKeyboard(){
        view.endEditing(true)
    }
}
