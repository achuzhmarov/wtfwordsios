import Foundation
import Localize_Swift
import NVActivityIndicatorView

class FeedbackVC: BaseModalVC {
    private let guiDataService: GuiDataService = serviceLocator.get(GuiDataService.self)
    private let feedbackService: FeedbackService = serviceLocator.get(FeedbackService.self)

    private let UNSENDED_ALERT_TEXT = "You haven't send your review. Is it ok?"
    private let IGNORE_BUTTON_TITLE = "Don't send"

    private let SUCCESS_SEND_TEXT = "Thank you for your feedback!"
    private let ERROR_SEND_TEXT = "There is a problem with internet connection. Please, try again later."

    private let FOREWORD_TEXT = "Hello, my name is Artem. I have developed this app. Feel free to write me any kind of feedback you have - errors, shortcomings, new ideas and all other sort of things. I will really appreciate it!"
    private let EMAIL_TITLE = "Email"
    private let EMAIL_PLACEHOLDER_TEXT = "Optional"

    private let BACK_BUTTON_TITLE = "Back"
    private let SEND_BUTTON_TITLE = "Send"

    private let LOADING_TEXT = "Sending..."

    @IBOutlet weak var backButton: BorderedButton!
    @IBOutlet weak var sendButton: BorderedButton!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var introTextLabel: UILabel!

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var feedbackInput: UITextView!

    @IBOutlet weak var modalWindowHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var verticalPaddingConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFeedback()
        feedbackInput.becomeFirstResponder()

        introTextLabel.text = FOREWORD_TEXT.localized()
        emailLabel.text = EMAIL_TITLE.localized()
        emailInput.placeholder = EMAIL_PLACEHOLDER_TEXT.localized()

        backButton.setTitleWithoutAnimation(BACK_BUTTON_TITLE.localized())
        sendButton.setTitleWithoutAnimation(SEND_BUTTON_TITLE.localized())

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func closeWindow(_ sender: AnyObject? = nil) {
        if (feedbackInput.text != "") {
            showUnsendedTextDialog()
        } else {
            super.closeWindow()
        }
    }

    override func modalWillClose() {
        dismissKeyboard()
        saveFeedback()
    }

    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.size.height

        let modalHeight = view.frame.size.height - keyboardHeight - verticalPaddingConstraint.constant * 2

        self.modalWindowHeightConstaint.constant = modalHeight
        self.view.layoutIfNeeded()
    }

    @IBAction func sendPressed(_ sender: AnyObject) {
        startLoader(LOADING_TEXT)

        feedbackService.sendFeedback(fromEmail: emailInput.text!, text: feedbackInput.text) {
            success -> Void in
                DispatchQueue.main.async {
                    self.stopLoader()

                    if (success) {
                        self.feedbackInput.text = ""

                        WTFOneButtonAlert.show(self.SUCCESS_SEND_TEXT.localized(), message: "") { () -> Void in
                            super.closeWindow()
                        }
                    } else {
                        WTFOneButtonAlert.show(self.ERROR_SEND_TEXT.localized(), message: "")
                    }
                }
            }
    }

    private func showUnsendedTextDialog() {
        WTFTwoButtonsAlert.show(UNSENDED_ALERT_TEXT.localized(),
                message: nil,
                firstButtonTitle: IGNORE_BUTTON_TITLE.localized(),
                alertButtonAction: { () -> Void in
                    super.closeWindow()
                }
        )
    }

    private func loadFeedback() {
        emailInput.text = guiDataService.getFeedbackEmail()
        feedbackInput.text = guiDataService.getFeedbackText()
    }

    private func saveFeedback() {
        guiDataService.updateFeedbackEmail(emailInput.text!)
        guiDataService.updateFeedbackText(feedbackInput.text!)
    }
}
