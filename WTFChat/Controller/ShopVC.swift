import Foundation
import Localize_Swift

class ShopVC: BaseModalVC {
    private let inAppService: InAppService = serviceLocator.get(InAppService.self)
    private let adService: AdService = serviceLocator.get(AdService.self)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)

    @IBOutlet weak var backButton: BorderedButton!

    @IBOutlet weak var hintsTitle: UILabel!
    @IBOutlet weak var buyHintsTitle: UILabel!

    @IBOutlet weak var freeHintsTitle: UILabel!
    @IBOutlet weak var freeHintsBuyButton: BorderedButton!

    @IBOutlet weak var dailyHintsTitle: UILabel!
    @IBOutlet weak var dailyHintsBuyButton: BorderedButton!
    @IBOutlet weak var dailyHintsRestoreButton: BorderedButton!

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

    private let CONNECTION_ERROR_TEXT = "Please, check if you have a stable internet connection. Then use 'Restore' button. If you still don't get your purchase, please, restart the app.".localized()
    private let RESTORE_TITLE = "Restore purchased content?".localized()
    private let RESTORE_BUTTON_TITLE = "Restore".localized()
    private let PAID_TITLE = "Paid".localized()
    private let NO_ADS_TITLE = "No more ads".localized()
    private let NO_ADS_MESSAGE = "Try again later".localized()
    private let ERROR_TITLE = "Error".localized()
    private let SUCCESS_TTITLE = "Success".localized()
    private let UNKNOWN_ERROR_TEXT = "Unknown error occured.".localized()
    private let BUY_ERROR_TEXT = "Can't buy".localized()
    private let RESTORED_SUCCESSFULLY_TEXT = "Restored successfully".localized()
    private let RESTORED_ERROR_TEXT = "can't be restored".localized()
    private let VIEW_AD_TITLE = "View Ad".localized()
    private let BACK_TEXT = "Back".localized()
    private let HINTS_TEXT = "WTF:".localized()
    private let BUY_HINTS_TEXT = "Buy WTF".localized()
    private let FREE_HINTS_TEXT = "Get Free WTF".localized()
    private let DAILY_HINTS_TEXT = "X2 Daily WTF".localized()

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

        freeHintsBuyButton.setTitleWithoutAnimation(VIEW_AD_TITLE)
        dailyHintsRestoreButton.setTitleWithoutAnimation(RESTORE_BUTTON_TITLE)
        backButton.setTitleWithoutAnimation(BACK_TEXT)

        hintsTitle.text = HINTS_TEXT + " "
        buyHintsTitle.text = BUY_HINTS_TEXT
        freeHintsTitle.text = FREE_HINTS_TEXT
        dailyHintsTitle.text = DAILY_HINTS_TEXT

        //resize font to get all text visible
        dailyHintsTitle.numberOfLines = 1
        dailyHintsTitle.adjustsFontSizeToFitWidth = true
        dailyHintsTitle.lineBreakMode = .byClipping

        lastWtfCount = currentUserService.getUserWtf()

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

    fileprivate func addPressedHandlersForProducts() {
        for (productId, productButton) in productButtons {
            if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
                productButton.addTarget(self, action: #selector(ShopVC.buyButtonPressed(_:)), for: .touchUpInside)
            }
        }

        dailyHintsRestoreButton.addTarget(self, action: #selector(ShopVC.restoreButtonPressed(_:)), for: .touchUpInside)
        freeHintsBuyButton.addTarget(self, action: #selector(ShopVC.showAdAlert(_:)), for: .touchUpInside)
    }

    func buyButtonPressed(_ sender: BorderedButton) {
        let productId = getProductRefByButton(sender)
        inAppService.showBuyAlert(productId)
    }

    func restoreButtonPressed(_ sender: BorderedButton) {
        WTFTwoButtonsAlert.show(RESTORE_TITLE,
                message: "",
                firstButtonTitle: RESTORE_BUTTON_TITLE) { () -> Void in
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
        var hintsTitleText = HINTS_TEXT + " " + String(newWtfCount)

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
                productButton.setTitleWithoutAnimation(PAID_TITLE)
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
            WTFOneButtonAlert.show(NO_ADS_TITLE, message: NO_ADS_MESSAGE) { () -> Void in
                self.reloadData()
            }
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
                    WTFOneButtonAlert.show(self.ERROR_TITLE, message: self.BUY_ERROR_TEXT + " " + productTitle + ". " + self.CONNECTION_ERROR_TEXT)
                })
            }
        } else {
            DispatchQueue.main.async(execute: {
                self.reloadData()
                WTFOneButtonAlert.show(self.ERROR_TITLE, message: self.UNKNOWN_ERROR_TEXT + " " + self.CONNECTION_ERROR_TEXT)
            })
        }
    }

    func productRestore(_ notification: Notification) {
        DispatchQueue.main.async(execute: {
            self.reloadData()

            if (self.isRestoreInProgress) {
                self.isRestoreInProgress = false
                WTFOneButtonAlert.show(self.SUCCESS_TTITLE, message: self.RESTORED_SUCCESSFULLY_TEXT)
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
                    WTFOneButtonAlert.show(self.ERROR_TITLE, message: productTitle + " " + self.RESTORED_ERROR_TEXT)
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
