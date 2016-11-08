import Foundation
import StoreKit
import Localize_Swift

class InAppService: Service {
    fileprivate let inAppHelper: InAppHelper

    fileprivate var products = [SKProduct]()

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

    func getHintsProductTitle(_ productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            let titleParts = product.localizedTitle.components(separatedBy: " ")
            return titleParts[0]
        }

        return nil
    }

    func getProductTitle(_ productId: ProductIdentifier) -> String? {
        if let product = inAppHelper.getProduct(productId) {
            return product.localizedTitle.localized()
        }
        
        return nil
    }
    
    func getProductDescription(_ productId: ProductIdentifier) -> String? {
        if (IAPProducts.CONSUMABLE.contains(productId)) {
            return ""
        }

        if let product = inAppHelper.getProduct(productId) {
            return product.localizedDescription.localized()
        }
        
        return nil
    }
    
    func getProductPrice(_ productId: ProductIdentifier) -> String? {
        if !canMakePayments() {
            return "-"
        }
        
        if isPurchased(productId) {
            return "Paid".localized()
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
        
        let productName = getProductTitle(productId)
        let productPrice = getProductPrice(productId)
        let productDescription = getProductDescription(productId)
        
        WTFTwoButtonsAlert.show("Buy".localized() + " " + productName! + " " + "for".localized() + " " + productPrice!,
            message: productDescription!,
            firstButtonTitle: "Buy".localized(),
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
