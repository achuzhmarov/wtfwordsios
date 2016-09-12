import Foundation

class ShopVC: BaseModalVC {
    private let inAppService: InAppService = serviceLocator.get(InAppService)
    private let adColonyService: AdColonyService = serviceLocator.get(AdColonyService)
    private let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService)

    @IBOutlet weak var userHintsCount: UILabel!

    @IBOutlet weak var freeHintsBuyButton: BorderedButton!

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

    private let CONNECTION_ERROR_TEXT = "Please, check if you have a stable internet connection. Then use 'Restore' button. If you still don't get your purchase, please, restart the app."

    private var productTitles = [ProductIdentifier: UILabel]()
    private var productButtons = [ProductIdentifier: BorderedButton]()

    private var isRestoreInProgress: Bool = false

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

        reloadData()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func viewWillAppear(animated: Bool) {
        reloadData()

        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productPurchased(_:)), name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productPurchasedError(_:)), name: IAPHelperProductPurchasedErrorNotification, object: nil)

        // Subscribe to a notification that fires when a product is restored.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productRestore(_:)), name: IAPHelperProductRestoreNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productRestoreError(_:)), name: IAPHelperProductRestoreErrorNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    private func addPressedHandlersForProducts() {
        for (productId, productButton) in productButtons {
            if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
                productButton.addTarget(self, action: #selector(ShopVC.buyButtonPressed(_:)), forControlEvents: .TouchUpInside)
            }
        }

        dailyHintsRestoreButton.addTarget(self, action: #selector(ShopVC.restoreButtonPressed(_:)), forControlEvents: .TouchUpInside)
        freeHintsBuyButton.addTarget(self, action: #selector(ShopVC.showAdAlert(_:)), forControlEvents: .TouchUpInside)
    }

    func buyButtonPressed(sender: BorderedButton) {
        let productId = getProductRefByButton(sender)
        inAppService.showBuyAlert(productId)
    }

    func restoreButtonPressed(sender: BorderedButton) {
        WTFTwoButtonsAlert.show("Restore purchased",
                message: "Are you sure you want to restore purchased content?",
                firstButtonTitle: "Restore") { () -> Void in
            self.isRestoreInProgress = true
            self.inAppService.restorePurchased()
        }
    }

    private func getProductRefByButton(button: BorderedButton) -> ProductIdentifier {
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

    private func updateProductTitles() {
        for (productId, productTitle) in productTitles {
            productTitle.text = inAppService.getHintsProductTitle(productId)
        }
    }

    private func updateProductButtons() {
        for (productId, productButton) in productButtons {
            if (inAppService.isPurchased(productId)) {
                productButton.setTitle("Paid", forState: .Normal)
                productButton.updateGradient(Gradient.Success)
            } else if inAppService.canPurchase(productId) {
                let priceString = inAppService.getProductPrice(productId)
                productButton.setTitle(priceString, forState: .Normal)
                productButton.updateGradient(Gradient.Ciphered)
            } else {
                productButton.setTitle("-", forState: .Normal)
                productButton.updateGradient(Gradient.Ignored)
            }
        }
    }

    private func updateRestoreButtonVisibility() {
        let dailyHintsProductId = IAPProducts.HINTS_X2

        if (!inAppService.isPurchased(dailyHintsProductId) && inAppService.canPurchase(dailyHintsProductId)) {
            dailyHintsRestoreButton.hidden = false
        } else {
            dailyHintsRestoreButton.hidden = true
        }
    }

    func showAdAlert(sender: BorderedButton) {
        if currentUserService.canAddFreeAdHint() && adColonyService.hasAd() {
            adColonyService.showAd({ () -> Void in
                self.currentUserService.addFreeHint()
                self.reloadData()
            })
        } else {
            WTFOneButtonAlert.show("No more ads", message: "Try again later") { () -> Void in
                self.reloadData()
            }
        }
    }

    func productPurchased(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.reloadData()
        })
    }

    func productPurchasedError(notification: NSNotification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String

            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.reloadData()
                    WTFOneButtonAlert.show("Error", message: "\(productTitle) purchase error. \(self.CONNECTION_ERROR_TEXT)")
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.reloadData()
                WTFOneButtonAlert.show("Error", message: "Unknown error occured. \(self.CONNECTION_ERROR_TEXT)")
            })
        }
    }

    func productRestore(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.reloadData()

            if (self.isRestoreInProgress) {
                self.isRestoreInProgress = false
                WTFOneButtonAlert.show("Success", message: "Restored successfully")
            }
        })
    }

    func productRestoreError(notification: NSNotification) {
        let productIdentifier = notification.object as! String

        if let productTitle = inAppService.getProductTitle(productIdentifier) {
            dispatch_async(dispatch_get_main_queue(), {
                self.reloadData()

                if (self.isRestoreInProgress) {
                    self.isRestoreInProgress = false
                    WTFOneButtonAlert.show("Error", message: "\(productTitle) can't be restored")
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
