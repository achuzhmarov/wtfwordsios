import Foundation
import StoreKit
import Localize_Swift

class InAppService: Service {
    fileprivate let inAppHelper: InAppHelper

    fileprivate var products = [SKProduct]()

    private let BUY_TEXT = "Buy"
    private let FOR_TEXT = "for"
    private let PAID_TEXT = "Paid"

    init(inAppHelper: InAppHelper) {
        self.inAppHelper = inAppHelper
    }

    override func initService() {
        inAppHelper.requestProductsWithCompletionHandler { success, products in
            if success {
                self.products = products
            }
        }
    }
    
    func restorePurchased() {
        inAppHelper.restoreCompletedTransactions()
    }
    
    func purchaseProduct(_ productId: ProductIdentifier) {
        if !canPurchase(productId) {
            return
        }
        
        if let product = inAppHelper.getProduct(productId) {
            inAppHelper.purchaseProduct(product)
        }
    }

    func getWtfProductTitle(_ productId: ProductIdentifier) -> String {
        return String(inAppHelper.getWtfCount(productId))
    }

    func getProductTitle(_ productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            //TODO - for backward compatibility
            var productName = product.localizedTitle.replace("hints", with: "WTF")
            if (IAPProducts.isConsumable(productId)) {
                productName = String(inAppHelper.getWtfCount(productId)) + " WTF"
            }

            return productName.localized()
        }
        
        return nil
    }
    
    func getProductDescription(_ productId: ProductIdentifier) -> String? {
        if (IAPProducts.CONSUMABLE.contains(productId)) {
            return ""
        }

        if let product = inAppHelper.getProduct(productId) {
            return product.localizedDescription.replace("hints", with: "WTF").localized()
        }
        
        return nil
    }
    
    func getProductPrice(_ productId: ProductIdentifier) -> String? {
        if !canMakePayments() {
            return "-"
        }
        
        if isPurchased(productId) {
            return PAID_TEXT.localized()
        }
        
        if let product = inAppHelper.getProduct(productId) {
            return product.localizedPrice().localized()
        }
        
        return nil
    }
    
    func canPurchase(_ productId: ProductIdentifier) -> Bool {
        if canMakePayments() && isProductExists(productId) {
            return true
        }
    
        return false
    }
    
    func isPurchased(_ productId: ProductIdentifier) -> Bool {
        return inAppHelper.isProductPurchased(productId)
    }
    
    func showBuyAlert(_ productId: ProductIdentifier, cancelFunc: (() -> Void)? = nil) {
        if (!canPurchase(productId) || isPurchased(productId)) {
            return
        }
        
        let productName = getProductTitle(productId)!
        let productPrice = getProductPrice(productId)
        let productDescription = getProductDescription(productId)!
        
        WTFTwoButtonsAlert.show(BUY_TEXT.localized() + " " + productName + " " + FOR_TEXT.localized() + " " + productPrice!,
            message: productDescription,
            firstButtonTitle: BUY_TEXT.localized(),
            alertButtonAction: { () -> Void in
                self.purchaseProduct(productId)
            }, cancelButtonAction: { () -> Void in
                cancelFunc?()
        })
    }
    
    fileprivate func isProductExists(_ productId: ProductIdentifier) -> Bool {
        if inAppHelper.getProduct(productId) != nil {
            return true
        }
        
        return false
    }
    
    fileprivate func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
}
