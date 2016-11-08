import Foundation
import Localize_Swift

class ShopVC: BaseModalVC {
    fileprivate let inAppService: InAppService = serviceLocator.get(InAppService.self)
    fileprivate let adService: AdService = serviceLocator.get(AdService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)

    @IBOutlet weak var backButton: BorderedButton!

    @IBOutlet weak var userHintsCount: UILabel!
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

    fileprivate let CONNECTION_ERROR_TEXT = "Please, check if you have a stable internet connection. Then use 'Restore' button. If you still don't get your purchase, please, restart the app.".localized()
    fileprivate let RESTORE_TITLE = "Restore purchased content?".localized()
    fileprivate let RESTORE_BUTTON_TITLE = "Restore".localized()
    fileprivate let PAID_TITLE = "Paid".localized()
    fileprivate let NO_ADS_TITLE = "No more ads".localized()
    fileprivate let NO_ADS_MESSAGE = "Try again later".localized()
    fileprivate let ERROR_TITLE = "Error".localized()
    fileprivate let SUCCESS_TTITLE = "Success".localized()
    fileprivate let UNKNOWN_ERROR_TEXT = "Unknown error occured.".localized()
    fileprivate let BUY_ERROR_TEXT = "Can't buy".localized()
    fileprivate let RESTORED_SUCCESSFULLY_TEXT = "Restored successfully".localized()
    fileprivate let RESTORED_ERROR_TEXT = "can't be restored".localized()
    fileprivate let VIEW_AD_TITLE = "View Ad".localized()
    fileprivate let BACK_TEXT = "Back".localized()
    fileprivate let HINTS_TEXT = "Hints:".localized()
    fileprivate let BUY_HINTS_TEXT = "Buy Hints".localized()
    fileprivate let FREE_HINTS_TEXT = "Get Free Hint".localized()
    fileprivate let DAILY_HINTS_TEXT = "X2 Daily Hints".localized()

    fileprivate var productTitles = [ProductIdentifier: UILabel]()
    fileprivate var productButtons = [ProductIdentifier: BorderedButton]()

    fileprivate var isRestoreInProgress: Bool = false

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

        freeHintsBuyButton.setTitle(VIEW_AD_TITLE, for: UIControlState())
        dailyHintsRestoreButton.setTitle(RESTORE_BUTTON_TITLE, for: UIControlState())
        backButton.setTitle(BACK_TEXT, for: UIControlState())

        hintsTitle.text = HINTS_TEXT + " "
        buyHintsTitle.text = BUY_HINTS_TEXT
        freeHintsTitle.text = FREE_HINTS_TEXT
        dailyHintsTitle.text = DAILY_HINTS_TEXT

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
        userHintsCount.text = String(currentUserService.getUserHints())

        updateProductTitles()
        updateProductButtons()
        updateRestoreButtonVisibility()
    }

    fileprivate func updateProductTitles() {
        for (productId, productTitle) in productTitles {
            productTitle.text = inAppService.getHintsProductTitle(productId)
        }
    }

    fileprivate func updateProductButtons() {
        for (productId, productButton) in productButtons {
            if (inAppService.isPurchased(productId)) {
                productButton.setTitle(PAID_TITLE, for: UIControlState())
                productButton.updateGradient(Gradient.Success)
            } else if inAppService.canPurchase(productId) {
                let priceString = inAppService.getProductPrice(productId)
                productButton.setTitle(priceString, for: UIControlState())
                productButton.updateGradient(Gradient.Ciphered)
            } else {
                productButton.setTitle("-", for: UIControlState())
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
        if currentUserService.canAddFreeAdHint() && adService.hasAd() {
            adService.showAd({ () -> Void in
                self.currentUserService.addFreeHint()
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
            decipherVC.hintsBought()
        }
    }
}
