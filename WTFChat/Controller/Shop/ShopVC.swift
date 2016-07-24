import Foundation

class ShopVC: BaseModalVC {
    private let inAppService: InAppService = serviceLocator.get(InAppService)
    private let userService: UserService = serviceLocator.get(UserService)
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

        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productPurchased(_:)), name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productPurchasedError(_:)), name: IAPHelperProductPurchasedErrorNotification, object: nil)

        // Subscribe to a notification that fires when a product is restored.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productRestore(_:)), name: IAPHelperProductRestoreNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopVC.productRestoreError(_:)), name: IAPHelperProductRestoreErrorNotification, object: nil)

        updateTable()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func viewWillAppear(animated: Bool) {
        updateTable()
    }

    private func addPressedHandlersForProducts() {
        for (productId, productButton) in productButtons {
            if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
                productButton.addTarget(self, action: #selector(ShopVC.buyButtonPressed(_:)), forControlEvents: .TouchUpInside)
            }
        }

        dailyHintsRestoreButton.addTarget(self, action: #selector(ShopVC.restoreButtonPressed(_:)), forControlEvents: .TouchUpInside)
    }

    func buyButtonPressed(sender: BorderedButton) {
        let productId = getProductRefByButton(sender)
        inAppService.showBuyAlert(productId)
    }

    func restoreButtonPressed(sender: BorderedButton) {
        WTFTwoButtonsAlert.show("Restore purchased",
                message: "Are you sure you want to restore purchased content?",
                firstButtonTitle: "Ok",
                secondButtonTitle: "Cancel") { () -> Void in
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

    func updateTable() {
        updateProductTitles()
        updateProductButtons()
        updateFreeHints()
        updateRestoreButtonVisibility()
    }

    private func updateProductTitles() {
        for (productId, productTitle) in productTitles {
            productTitle.text = inAppService.getProductTitle(productId)
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

    private func updateFreeHints() {
        if currentUserService.canAddFreeAdHint() && adColonyService.hasAd() {
            freeHintsBuyButton.updateGradient(Gradient.Ciphered)
        } else {
            freeHintsBuyButton.setTitle("No ads", forState: .Normal)
            freeHintsBuyButton.updateGradient(Gradient.Ignored)
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

    func showAdAlert() {
        if currentUserService.canAddFreeAdHint() && adColonyService.hasAd() {
            adColonyService.showAd({ () -> Void in
                self.userService.addFreeAdHint()

                dispatch_async(dispatch_get_main_queue(), {
                    WTFOneButtonAlert.show("Free hint",
                            message: "You have just received a free hint",
                            firstButtonTitle: "Ok") { () -> Void in
                        self.productPurchased(nil)
                    }
                })
            })
        } else {
            WTFOneButtonAlert.show("No more ads",
                    message: "Try again tomorrow",
                    firstButtonTitle: "Ok") { () -> Void in
                self.updateTable()
            }
        }
    }

    func productPurchased(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()
        })
    }

    let connectionErrorMessage = "Please, check if you have a stable internet connection. Then use 'Restore' button. If you still don't get your purchase, please, restart the app."

    func productPurchasedError(notification: NSNotification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String

            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTable()

                    WTFOneButtonAlert.show("Error",
                            message: "\(productTitle) purchase error. \(self.connectionErrorMessage)",
                            firstButtonTitle: "Ok")
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTable()

                WTFOneButtonAlert.show("Error",
                        message: "Unknown error occured. \(self.connectionErrorMessage)",
                        firstButtonTitle: "Ok")
            })
        }
    }

    func productRestore(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()

            if (self.isRestoreInProgress) {
                self.isRestoreInProgress = false

                WTFOneButtonAlert.show("Success",
                        message: "Restored successfully",
                        firstButtonTitle: "Ok")
            }
        })
    }

    func productRestoreError(notification: NSNotification) {
        let productIdentifier = notification.object as! String

        if let productTitle = inAppService.getProductTitle(productIdentifier) {
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTable()

                if (self.isRestoreInProgress) {
                    self.isRestoreInProgress = false

                    WTFOneButtonAlert.show("Error",
                            message: "\(productTitle) can't be restored",
                            firstButtonTitle: "Ok")
                }
            })
        }
    }
}
