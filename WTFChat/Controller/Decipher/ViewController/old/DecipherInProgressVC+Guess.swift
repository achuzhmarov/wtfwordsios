import Foundation
import Localize_Swift

extension DecipherInProgressVC: UITextFieldDelegate {

    //delegate enterPressed for guessField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        tryButtonPressed(tryButton)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {   //delegate method
        UIView.setAnimationsEnabled(false)
    }

    @IBAction func guessTextChanged(_ sender: AnyObject) {
        if let guessText = guessTextField.text {
            tryButton.isEnabled = (guessText.characters.count > 0)
        } else {
            tryButton.isEnabled = false
        }
    }

    @IBAction func tryButtonPressed(_ sender: AnyObject) {
        if (guessTextField.text!.characters.count > 1024) {
            WTFOneButtonAlert.show("Too many characters".localized(),
                    message: "Your guess should be less than 1024 characters".localized())

            return
        }

        messageCipherService.decipher(message, guessText: guessTextField.text!)

        let guessWords = guessTextField.text!.characters.split {$0 == " "}.map { String($0) }

        wordsTableView.updateMessage(message, tries: guessWords)
        guessTextField.text = ""
        tryButton.isEnabled = false

        if (message.deciphered) {
            gameOver()
        } else {
            updateMessage()
        }
    }

    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        UIView.setAnimationsEnabled(true)

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = keyboardFrame.size.height
        })
    }

    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomViewConstraint.constant = 0
        })
    }

    func dismissKeyboard(){
        view.endEditing(true)
    }
}
