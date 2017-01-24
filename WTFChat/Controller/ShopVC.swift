import Foundation
import Localize_Swift

class ShopVC: BaseModalVC, UITextFieldDelegate {
    private let inAppService: InAppService = serviceLocator.get(InAppService.self)
    private let adService: AdService = serviceLocator.get(AdService.self)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    private let rewardCodeService: RewardCodeService = serviceLocator.get(RewardCodeService.self)

    @IBOutlet weak var backButton: BorderedButton!

    @IBOutlet weak var hintsTitle: UILabel!
    @IBOutlet weak var buyHintsTitle: UILabel!

    @IBOutlet weak var freeHintsTitle: UILabel!
    @IBOutlet weak var freeHintsBuyButton: BorderedButton!

    @IBOutlet weak var dailyHintsTitle: UILabel!
    @IBOutlet weak var dailyHintsBuyButton: BorderedButton!
    @IBOutlet weak var dailyHintsRestoreButton: BorderedButton!

    @IBOutlet weak var rewardCodeTitle: UILabel!
    @IBOutlet weak var rewardCodeInput: UITextField!
    @IBOutlet weak var rewardCodeButton: BorderedButton!

    @IBOutlet weak var hints1Title: UILabel!
    @IBOutlet weak var hints1BuyButton: BorderedButton!
    @IBOutlet weak var hints2Title: UILabel!
    @IBOutlet weak var hints2BuyButton: BorderedButton!
    @IBOutlet weak var hints3Title: UILabel!
    @IBOutlet weak var hints3BuyButton: BorderedButton!
    @IBOutlet weak var hints4Title: UILabel!
    @IBOutlet weak var hints4BuyButton: BorderedButton!
    @IBOutlet weak var hints5Title: UILabel!
    @IBOutlet weak var hints5BuyButton: BorderedButton!
    @IBOutlet weak var hints6Title: UILabel!
    @IBOutlet weak var hints6BuyButton: BorderedButton!

    @IBOutlet weak var modalWindowHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var modalWindowTopPaddingConstraint: NSLayoutConstraint!

    private let CONNECTION_ERROR_TEXT = "Please, check if you have a stable internet connection. Then use 'Restore' button. If you still don't get your purchase, please, restart the app."

    private let RESTORE_TITLE = "Restore purchased content?"
    private let RESTORE_BUTTON_TITLE = "Restore"
    private let PAID_TITLE = "Paid"

    private let NO_ADS_TITLE = "No more ads"
    private let NO_ADS_MESSAGE = "Try again later"

    private let ERROR_TITLE = "Error"
    private let SUCCESS_TTITLE = "Success"
    private let UNKNOWN_ERROR_TEXT = "Unknown error occured."
    private let BUY_ERROR_TEXT = "Can't buy"

    private let RESTORED_SUCCESSFULLY_TEXT = "Restored successfully"
    private let RESTORED_ERROR_TEXT = "can't be restored"

    private let VIEW_AD_TITLE = "View Ad"
    private let BACK_TEXT = "Back"
    private let HINTS_TEXT = "WTF:"

    private let BUY_HINTS_TEXT = "Buy WTF"
    private let FREE_HINTS_TEXT = "Get Free WTF"
    private let DAILY_HINTS_TEXT = "X2 Daily WTF"

    private let REWARD_CODE_TEXT = "Enter Code"
    private let REWARD_CODE_BUTTON_TITLE = "Redeem"
    private let EMPTY_REWARD_CODE_MESSAGE = "Please, enter your reward code!"

    private let LOADING_TEXT = "Sending"

    private var productTitles = [ProductIdentifier: UILabel]()
    private var productButtons = [ProductIdentifier: BorderedButton]()

    private var isRestoreInProgress: Bool = false
    private var lastWtfCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        productTitles = [
                IAPProducts.HINTS_1: hints1Title,
                IAPProducts.HINTS_2: hints2Title,
                IAPProducts.HINTS_3: hints3Title,
                IAPProducts.HINTS_4: hints4Title,
                IAPProducts.HINTS_5: hints5Title,
                IAPProducts.HINTS_6: hints6Title
        ]

        productButtons = [
                IAPProducts.HINTS_1: hints1BuyButton,
                IAPProducts.HINTS_2: hints2BuyButton,
                IAPProducts.HINTS_3: hints3BuyButton,
                IAPProducts.HINTS_4: hints4BuyButton,
                IAPProducts.HINTS_5: hints5BuyButton,
                IAPProducts.HINTS_6: hints6BuyButton,
                IAPProducts.HINTS_X2: dailyHintsBuyButton
        ]

        addPressedHandlersForProducts()

        freeHintsBuyButton.setTitleWithoutAnimation(VIEW_AD_TITLE.localized())
        dailyHintsRestoreButton.setTitleWithoutAnimation(RESTORE_BUTTON_TITLE.localized())
        rewardCodeButton.setTitleWithoutAnimation(REWARD_CODE_BUTTON_TITLE.localized())
        backButton.setTitleWithoutAnimation(BACK_TEXT.localized())

        hintsTitle.text = HINTS_TEXT.localized() + " "
        buyHintsTitle.text = BUY_HINTS_TEXT.localized()
        freeHintsTitle.text = FREE_HINTS_TEXT.localized()
        dailyHintsTitle.text = DAILY_HINTS_TEXT.localized()
        rewardCodeTitle.text = REWARD_CODE_TEXT.localized()

        //resize font to get all text visible
        dailyHintsTitle.numberOfLines = 1
        dailyHintsTitle.adjustsFontSizeToFitWidth = true
        dailyHintsTitle.lineBreakMode = .byClipping

        lastWtfCount = currentUserService.getUserWtf()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)

        rewardCodeInput.delegate = self

        view.layoutIfNeeded()
        setModalTopPadding()

        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self);
    }

    override func viewWillAppear(_ animated: Bool) {
        reloadData()

        // Subscribe to a notification that fires when a product is purchased.
        NotificationCenter.default.addObserver(self, selector: #selector(ShopVC.productPurchased(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShopVC.productPurchasedError(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedErrorNotification), object: nil)

        // Subscribe to a notification that fires when a product is restored.
        NotificationCenter.default.addObserver(self, selector: #selector(ShopVC.productRestore(_:)), name: NSNotification.Name(rawValue: IAPHelperProductRestoreNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ShopVC.productRestoreError(_:)), name: NSNotification.Name(rawValue: IAPHelperProductRestoreErrorNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self);
    }

    override func modalWillClose() {
        dismissKeyboard()
    }

    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        setModalTopPadding(keyboardHeight: keyboardFrame.size.height)
    }

    func keyboardWillHide(_ notification: Notification) {
        setModalTopPadding()
    }

    func setModalTopPadding(keyboardHeight: CGFloat = 0) {
        let topPadding = (view.frame.size.height - keyboardHeight - modalWindowHeightConstaint.constant) / CGFloat(2)
        modalWindowTopPaddingConstraint.constant = topPadding

        view.layoutIfNeeded()
    }

    private func addPressedHandlersForProducts() {
        for (productId, productButton) in productButtons {
            if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
                productButton.addTarget(self, action: #selector(self.buyButtonPressed), for: .touchUpInside)
            }
        }

        dailyHintsRestoreButton.addTarget(self, action: #selector(self.restoreButtonPressed), for: .touchUpInside)
        freeHintsBuyButton.addTarget(self, action: #selector(self.showAdAlert), for: .touchUpInside)
        rewardCodeButton.addTarget(self, action: #selector(self.redeemCode), for: .touchUpInside)
    }

    func buyButtonPressed(_ sender: BorderedButton) {
        let productId = getProductRefByButton(sender)
        inAppService.showBuyAlert(productId)
    }

    func restoreButtonPressed(_ sender: BorderedButton) {
        WTFTwoButtonsAlert.show(RESTORE_TITLE.localized(),
                message: "",
                firstButtonTitle: RESTORE_BUTTON_TITLE.localized()) { () -> Void in
            self.isRestoreInProgress = true
            self.inAppService.restorePurchased()
        }
    }

    fileprivate func getProductRefByButton(_ button: BorderedButton) -> ProductIdentifier {
        for (productId, productButton) in productButtons {
            if (productButton == button) {
                return productId
            }
        }

        fatalError("Button must be in productButtons")
    }

    func reloadData() {
        let newWtfCount = currentUserService.getUserWtf()
        var hintsTitleText = HINTS_TEXT.localized() + " " + String(newWtfCount)

        if (lastWtfCount < newWtfCount) {
            let difference = newWtfCount - lastWtfCount
            lastWtfCount = newWtfCount
            hintsTitleText += "(+" + String(difference) + ")"
        }

        hintsTitle.text = hintsTitleText

        updateProductTitles()
        updateProductButtons()
        updateRestoreButtonVisibility()
    }

    fileprivate func updateProductTitles() {
        for (productId, productTitle) in productTitles {
            productTitle.text = inAppService.getWtfProductTitle(productId)
        }
    }

    fileprivate func updateProductButtons() {
        for (productId, productButton) in productButtons {
            if (inAppService.isPurchased(productId)) {
                productButton.setTitleWithoutAnimation(PAID_TITLE.localized())
                productButton.updateGradient(Gradient.Success)
            } else if inAppService.canPurchase(productId) {
                let priceString = inAppService.getProductPrice(productId)
                productButton.setTitleWithoutAnimation(priceString)
                productButton.updateGradient(Gradient.Ciphered)
            } else {
                productButton.setTitleWithoutAnimation("-")
                productButton.updateGradient(Gradient.Ignored)
            }
        }
    }

    fileprivate func updateRestoreButtonVisibility() {
        let dailyHintsProductId = IAPProducts.HINTS_X2

        if (!inAppService.isPurchased(dailyHintsProductId) && inAppService.canPurchase(dailyHintsProductId)) {
            dailyHintsRestoreButton.isHidden = false
        } else {
            dailyHintsRestoreButton.isHidden = true
        }
    }

    func showAdAlert(_ sender: BorderedButton) {
        if currentUserService.canAddFreeAdWtf() && adService.hasAd() {
            adService.showAd({ () -> Void in
                //get random amount of wtf
                let wtf = Int(arc4random_uniform(UInt32(2))) + 1
                self.currentUserService.addFreeWtf(wtf)
                self.reloadData()
            })
        } else {
            WTFOneButtonAlert.show(NO_ADS_TITLE.localized(), message: NO_ADS_MESSAGE.localized()) { () -> Void in
                self.reloadData()
            }
        }
    }

    //delegate method for "return" pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        redeemCode()
        return false
    }

    func redeemCodePressed(_ sender: BorderedButton) {
        redeemCode()
    }

    func redeemCode() {
        if (rewardCodeInput.text != "") {
            startLoader(LOADING_TEXT.localized())

            rewardCodeService.getRewardForCode(code: rewardCodeInput.text!) {
                success in
                    DispatchQueue.main.async {
                        self.stopLoader()

                        if (success) {
                            self.rewardCodeInput.text = ""
                            self.dismissKeyboard()
                            self.reloadData()
                        }
                    }
            }

        } else {
            WTFOneButtonAlert.show(EMPTY_REWARD_CODE_MESSAGE.localized())
        }
    }

    func productPurchased(_ notification: Notification?) {
        DispatchQueue.main.async(execute: {
            self.reloadData()
        })
    }

    func productPurchasedError(_ notification: Notification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String

            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                DispatchQueue.main.async(execute: {
                    self.reloadData()
                    WTFOneButtonAlert.show(self.ERROR_TITLE.localized(), message: self.BUY_ERROR_TEXT.localized() + " " + productTitle + ". " + self.CONNECTION_ERROR_TEXT.localized())
                })
            }
        } else {
            DispatchQueue.main.async(execute: {
                self.reloadData()
                WTFOneButtonAlert.show(self.ERROR_TITLE.localized(), message: self.UNKNOWN_ERROR_TEXT.localized() + " " + self.CONNECTION_ERROR_TEXT.localized())
            })
        }
    }

    func productRestore(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.reloadData()

            if (self.isRestoreInProgress) {
                self.isRestoreInProgress = false
                WTFOneButtonAlert.show(self.SUCCESS_TTITLE.localized(), message: self.RESTORED_SUCCESSFULLY_TEXT.localized())
            }
        })
    }

    func productRestoreError(_ notification: Notification) {
        let productIdentifier = notification.object as! String

        if let productTitle = inAppService.getProductTitle(productIdentifier) {
            DispatchQueue.main.async(execute: {
                self.reloadData()

                if (self.isRestoreInProgress) {
                    self.isRestoreInProgress = false
                    WTFOneButtonAlert.show(self.ERROR_TITLE.localized(), message: productTitle + " " + self.RESTORED_ERROR_TEXT.localized())
                }
            })
        }
    }

    override func modalClosed() {
        if let decipherVC = presentingVC as? DecipherViewController {
            decipherVC.wtfBought()
        }
    }
}
